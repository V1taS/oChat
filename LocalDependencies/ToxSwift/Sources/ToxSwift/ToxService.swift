//
//  ToxService.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 7.05.2025.
//  Полная обновлённая версия, включающая bootstrap‑узлы.
//

import Foundation
import CTox
import CSodium

// MARK: – Реализация сервиса Tox как актора
/// Актор, реализующий протокол `ToxServiceProtocol` и оборачивающий c‑toxcore
public actor ToxService: ToxServiceProtocol {

  // MARK: Внутренние настройки
  var toxPointer: UnsafeMutablePointer<Tox>
  private var eventLoopTask: Task<Void, Never>

  let messageStream = AsyncStream<IncomingMessage>.makeStream()
  let friendEventStream = AsyncStream<FriendEvent>.makeStream()
  let fileEventStream = AsyncStream<FileEvent>.makeStream()
  let conferenceEventStream = AsyncStream<ConferenceEvent>.makeStream()
  let selfConnectionStream = AsyncStream<ConnectionState>.makeStream()

  // Храним исходные параметры, чтобы иметь возможность
  // пересоздать ядро без участия вызывающей стороны
  private var startOptions: ToxServiceOptions
  private var startBootstrap: [ToxNode]

  // MARK: Инициализация и завершение

  public init(options: ToxServiceOptions = .init(), bootstrapNodes: [ToxNode] = []) throws {
    // 0. Сохраняем параметры
    self.startOptions = options
    self.startBootstrap = bootstrapNodes
    self.toxPointer = try Self.makeCore(options: startOptions, bootstrapNodes: startBootstrap)
    self.eventLoopTask = Task.detached(priority: .background) { [tox = toxPointer] in
      let ctx = UnsafeMutableRawPointer(tox)
      while !Task.isCancelled {
        tox_iterate(tox, ctx)
        try? await Task.sleep(for: .milliseconds(Int(tox_iteration_interval(tox))))
      }
    }
    instances[UnsafeMutableRawPointer(toxPointer)] = WeakBox(self)
  }

  /// Корректно останавливает ядро (можно звать при уходе в бэкграунд)
  public func shutdown() async {
    selfConnectionStream.continuation.yield(.none)

    // 1. Глушим циклы
    eventLoopTask.cancel()
    avContext.loopTask?.cancel()

    _ = await eventLoopTask.result
    _ = await avContext.loopTask?.result

    // 2. Закрываем AV-подсистему, если она была
    if let av = avContext.avPtr {
      toxav_kill(av)
      avContext.avPtr = nil
    }
    // удаляем контекст, чтобы при новом запуске создался «с нуля»
    Self.contexts.removeValue(forKey: UnsafeMutableRawPointer(toxPointer))

    // 3. Чистим реестр сервисов
    instances.removeValue(forKey: UnsafeMutableRawPointer(toxPointer))

    // 4. Убиваем само ядро
    tox_kill(toxPointer)
  }

  /// Полный перезапуск с сохранением профиля
  public func restart() async throws {
    // 1. Экспортируем текущий state
    let saved = await exportSavedata()

    startOptions.savedata = saved
    startOptions.savedataType = .toxSave

    // 3. Глушим ядро
    await shutdown()

    // 4. Создаём новое с теми же опциями
    toxPointer = try Self.makeCore(options: startOptions,
                                   bootstrapNodes: startBootstrap)
    instances[UnsafeMutableRawPointer(toxPointer)] = WeakBox(self)

    // 5. Запускаем iterate-цикл
    eventLoopTask = Task.detached(priority: .background) { [tox = toxPointer] in
      let ctx = UnsafeMutableRawPointer(tox)
      while !Task.isCancelled {
        tox_iterate(tox, ctx)
        try? await Task.sleep(for: .milliseconds(Int(tox_iteration_interval(tox))))
      }
    }
  }

  // MARK: – Вспомогательная фабрика

  /// Создаёт новый `Tox`-инстанс, вешает ВСЕ колбэки и выполняет bootstrap.
  private static func makeCore(options: ToxServiceOptions, bootstrapNodes: [ToxNode])
    throws -> UnsafeMutablePointer<Tox>
  {
    // ─── 1. tox_new ───
    var errNew = TOX_ERR_NEW_OK
    var (cOpts, proxyDup, savedDup) = withUnsafeBridgeOptions(options)
    defer {
      if let proxyDup { free(proxyDup) }
      if let savedDup { savedDup.deallocate() }
    }

    guard let ptr = tox_new(&cOpts, &errNew),
          errNew  == TOX_ERR_NEW_OK else {
      throw ToxError.creationFailed(errNew)
    }

    // ─── 2. Bootstrap узлы ───
    if !bootstrapNodes.isEmpty {
      try self.bootstrapNodes(bootstrapNodes, on: ptr)
    }

    // ─── 3. Регистрируем ВСЕ callback-и ───
    tox_callback_friend_message(ptr,               friendMessageCallback)
    tox_callback_friend_request(ptr,               friendRequestCallback)
    tox_callback_friend_name(ptr,                  friendNameCallback)
    tox_callback_friend_status_message(ptr,        friendStatusMsgCallback)
    tox_callback_friend_status(ptr,                friendUserStatusCallback)
    tox_callback_friend_connection_status(ptr,     friendConnStatusCallback)
    tox_callback_friend_typing(ptr,                friendTypingCallback)
    tox_callback_friend_read_receipt(ptr,          friendReadReceiptCallback)
    tox_callback_friend_lossy_packet(ptr,          friendLossyPktCallback)
    tox_callback_friend_lossless_packet(ptr,       friendLosslessPktCallback)

    tox_callback_file_chunk_request(ptr,           fileChunkRequestCallback)
    tox_callback_file_recv(ptr,                    fileRecvCallback)
    tox_callback_file_recv_chunk(ptr,              fileRecvChunkCallback)
    tox_callback_file_recv_control(ptr,            fileRecvControlCallback)

    tox_callback_conference_invite(ptr,            conferenceInviteCb)
    tox_callback_conference_connected(ptr,         conferenceConnectedCb)
    tox_callback_conference_message(ptr,           conferenceMessageCb)
    tox_callback_conference_title(ptr,             conferenceTitleCb)
    tox_callback_conference_peer_name(ptr,         conferencePeerNameCb)
    tox_callback_conference_peer_list_changed(ptr, conferencePeerListChangedCb)

    tox_callback_self_connection_status(ptr,       selfConnectionStatusCallback)

    return ptr
  }

  deinit {
    Task {
      await shutdown()
    }
  }

  // MARK: – Публичный API

  public var friendEvents: AsyncStream<FriendEvent> {
    friendEventStream.stream
  }
  public var fileEvents: AsyncStream<FileEvent> {
    fileEventStream.stream
  }
  public var conferenceEvents: AsyncStream<ConferenceEvent> {
    conferenceEventStream.stream
  }
  public var connectionStatusEvents: AsyncStream<ConnectionState> {
    selfConnectionStream.stream
  }

  public func setUserStatus(_ status: UserStatus) async {
    tox_self_set_status(toxPointer, status.cValue)
  }

  public func getUserStatus() async -> UserStatus {
    let cStatus = tox_self_get_status(toxPointer)
    return UserStatus(rawValue: UInt8(cStatus.rawValue)) ?? .none
  }

  public func inviteToConference(friendID: UInt32,
                                 conferenceID: UInt32) throws {
    var err = TOX_ERR_CONFERENCE_INVITE_OK
    tox_conference_invite(toxPointer, friendID, conferenceID, &err)
    if err != TOX_ERR_CONFERENCE_INVITE_OK {
      throw ToxError.generic("conferenceInvite failed: \(err)")
    }
  }

  public func joinConference(fromFriend friendID: UInt32,
                             cookie: Data) throws -> UInt32 {
    var err = TOX_ERR_CONFERENCE_JOIN_OK
    return try cookie.withUnsafeBytes { buf -> UInt32 in
      guard let base = buf.baseAddress else {
        throw ToxError.generic("Invalid cookie buffer")
      }
      let id = tox_conference_join(toxPointer,
                                   friendID,
                                   base.assumingMemoryBound(to: UInt8.self),
                                   cookie.count,
                                   &err)
      if err != TOX_ERR_CONFERENCE_JOIN_OK {
        throw ToxError.generic("conferenceJoin failed: \(err)")
      }
      return id
    }
  }

  /// Покидает конференцию (групповой чат).
  public func leaveConference(_ conferenceID: UInt32,
                              partingMessage: String? = nil) async throws {
    // partingMessage в старом API не передаётся – оставляем для будущих версий
    var err = TOX_ERR_CONFERENCE_DELETE_OK
    tox_conference_delete(toxPointer, conferenceID, &err)

    guard err == TOX_ERR_CONFERENCE_DELETE_OK else {
      throw ToxError.conferenceDeleteFailed(err)
    }
  }

  public func getConferencePeerName(_ conferenceID: UInt32,
                                    peerID: UInt32) -> String {
    // 1. Размер имени
    let size = tox_conference_peer_get_name_size(toxPointer,
                                                 conferenceID,
                                                 peerID,
                                                 nil)
    guard size > 0 else { return "" }

    // 2. Само имя
    var buf = [UInt8](repeating: 0, count: Int(size))
    tox_conference_peer_get_name(toxPointer,
                                 conferenceID,
                                 peerID,
                                 &buf,
                                 nil)
    return String(bytes: buf, encoding: .utf8) ?? ""
  }

  public func conferenceList() -> [UInt32] {
    let count = tox_conference_get_chatlist_size(toxPointer)
    guard count > 0 else { return [] }
    var list = [UInt32](repeating: 0, count: Int(count))
    tox_conference_get_chatlist(toxPointer, &list)
    return list
  }

  public func getConferenceTitle(_ conferenceID: UInt32) -> String {
    let size = tox_conference_get_title_size(toxPointer, conferenceID, nil)
    guard size > 0 else { return "" }
    var buf = [UInt8](repeating: 0, count: Int(size))
    tox_conference_get_title(toxPointer, conferenceID, &buf, nil)
    return String(bytes: buf, encoding: .utf8) ?? ""
  }

  public func setConferenceTitle(_ conferenceID: UInt32,
                                 title: String) throws {
    var err = TOX_ERR_CONFERENCE_TITLE_OK
    try title.withCString { ptr in
      tox_conference_set_title(toxPointer,
                               conferenceID,
                               ptr,
                               title.utf8.count,
                               &err)
    }
    if err != TOX_ERR_CONFERENCE_TITLE_OK {
      throw ToxError.generic("setConferenceTitle failed: \(err)")
    }
  }

  public func getConferenceType(_ conferenceID: UInt32) -> ConferenceType {
    var err = TOX_ERR_CONFERENCE_GET_TYPE_OK
    let cType = tox_conference_get_type(toxPointer, conferenceID, &err)

    // Если возникла ошибка, по‑умолчанию считаем AV‑конференцией.
    guard err == TOX_ERR_CONFERENCE_GET_TYPE_OK else {
      print("[Tox] getConferenceType failed: \(err)")
      return .audioVideo
    }

    return ConferenceType(rawValue: cType.rawValue) ?? .audioVideo
  }

  public func controlFile(toFriend friendID: UInt32,
                          fileID: UInt32,
                          control: FileControl) throws {
    var err = TOX_ERR_FILE_CONTROL_OK
    tox_file_control(toxPointer, friendID, fileID, control.cValue, &err)
    if err != TOX_ERR_FILE_CONTROL_OK {
      throw ToxError.fileControlFailed(err)
    }
  }

  public func seekFile(toFriend friendID: UInt32,
                       fileID: UInt32,
                       position: UInt64) throws {
    var err = TOX_ERR_FILE_SEEK_OK
    tox_file_seek(toxPointer, friendID, fileID, position, &err)
    if err != TOX_ERR_FILE_SEEK_OK {
      throw ToxError.fileSeekFailed(err)
    }
  }

  public func getFileID(ofFriend friendID: UInt32,
                        at index: UInt32) -> UInt32? {
    var err: TOX_ERR_FILE_GET = TOX_ERR_FILE_GET_OK
    var fileID: UInt32 = 0

    let ok = tox_file_get_file_id(toxPointer,
                                  friendID,
                                  index,
                                  &fileID,
                                  &err)
    guard ok, err == TOX_ERR_FILE_GET_OK else { return nil }
    return fileID
  }

  public func getFriendName(_ friendID: UInt32) -> String {
    let len = tox_friend_get_name_size(toxPointer, friendID, nil)
    guard len > 0 else { return "" }
    var buf = [UInt8](repeating: 0, count: len)
    tox_friend_get_name(toxPointer, friendID, &buf, nil)
    return String(bytes: buf, encoding: .utf8) ?? ""
  }

  public func getFriendStatusMessage(_ friendID: UInt32) -> String {
    let len = tox_friend_get_status_message_size(toxPointer, friendID, nil)
    guard len > 0 else { return "" }
    var buf = [UInt8](repeating: 0, count: len)
    tox_friend_get_status_message(toxPointer, friendID, &buf, nil)
    return String(bytes: buf, encoding: .utf8) ?? ""
  }

  public func getFriendPublicKey(_ friendID: UInt32) -> Data {
    var pk = [UInt8](repeating: 0, count: kPublicKeySize)
    tox_friend_get_public_key(toxPointer, friendID, &pk, nil)
    return Data(pk)
  }

  public func getFriendUserStatus(_ friendID: UInt32) -> UserStatus {
    let cStatus = tox_friend_get_status(toxPointer, friendID, nil)
    return UserStatus(rawValue: UInt8(cStatus.rawValue)) ?? .none
  }

  public func getFriendLastOnline(_ friendID: UInt32) -> UInt64 {
    tox_friend_get_last_online(toxPointer, friendID, nil)
  }

  public func friendExists(_ friendID: UInt32) -> Bool {
    tox_friend_exists(toxPointer, friendID)
  }

  public func friendList() -> [UInt32] {
    let count = tox_self_get_friend_list_size(toxPointer)  // size_t
    guard count > 0 else { return [] }

    var ids = [UInt32](repeating: 0, count: Int(count))
    ids.withUnsafeMutableBufferPointer { buf in
      tox_self_get_friend_list(toxPointer, buf.baseAddress)
    }
    return ids
  }

  public static var libraryVersion: (major: UInt32, minor: UInt32, patch: UInt32) {
    (tox_version_major(), tox_version_minor(), tox_version_patch())
  }

  public static func isCompatible(major: UInt32,
                                  minor: UInt32,
                                  patch: UInt32) -> Bool {
    tox_version_is_compatible(major, minor, patch)
  }

  public func getOwnSecretKey() -> Data {
    var buffer = [UInt8](repeating: 0, count: kSecretKeySize)
    tox_self_get_secret_key(toxPointer, &buffer)
    return Data(buffer)
  }

  public func exportSavedata() async -> Data {
    let size = tox_get_savedata_size(toxPointer)
    var buf  = [UInt8](repeating: 0, count: Int(size))
    tox_get_savedata(toxPointer, &buf)
    return Data(buf)
  }

  public func getOwnAddress() -> String {
    var buf = [UInt8](repeating: 0, count: kAddressSize)
    tox_self_get_address(toxPointer, &buf)
    return Data(buf).hex
  }

  public func getOwnPublicKey() -> Data {
    var buffer = [UInt8](repeating: 0, count: kPublicKeySize)
    tox_self_get_public_key(toxPointer, &buffer)
    return Data(buffer)
  }

  public func setDisplayName(_ name: String) throws {
    var errInfo = TOX_ERR_SET_INFO_OK
    try name.withCString { ptr in
      guard tox_self_set_name(toxPointer, ptr, name.utf8.count, &errInfo) else {
        throw ToxError.generic("setDisplayName failed: \(errInfo)")
      }
    }
  }

  public func getDisplayName() -> String {
    let length = tox_self_get_name_size(toxPointer)
    guard length > 0 else { return "" }
    var buffer = [UInt8](repeating: 0, count: length)
    tox_self_get_name(toxPointer, &buffer)
    return String(bytes: buffer, encoding: .utf8) ?? ""
  }

  public func setStatusMessage(_ message: String) throws {
    var errInfo = TOX_ERR_SET_INFO_OK
    try message.withCString { ptr in
      guard tox_self_set_status_message(toxPointer, ptr, message.utf8.count, &errInfo) else {
        throw ToxError.generic("setStatusMessage failed: \(errInfo)")
      }
    }
  }

  public func getFriendAddress(_ friendID: UInt32) async -> String {
    var pk = [UInt8](repeating: 0, count: kPublicKeySize)
    tox_friend_get_public_key(toxPointer, friendID, &pk, nil)
    return Data(pk).hex
  }

  public func acceptFriendRequest(publicKey: Data) async throws -> UInt32 {
    guard publicKey.count == 32 else {
      throw ToxError.generic("Public key must be 32 raw bytes")
    }

    var err = TOX_ERR_FRIEND_ADD_OK
    let friendID = try publicKey.withUnsafeBytes { bytes in
      guard let pkPtr = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self)
      else { throw ToxError.generic("Invalid PK buffer") }

      return tox_friend_add_norequest(toxPointer, pkPtr, &err)
    }

    if err != TOX_ERR_FRIEND_ADD_OK {
      throw ToxError.friendAddFailed(err)
    }
    return friendID
  }

  public func addFriend(withAddress address: Data, greeting message: String) async throws -> UInt32 {
    guard address.count == 38 else {
      throw ToxError.generic("Address must be 38 raw bytes")
    }
    guard message.utf8.count <= TOX_MAX_FRIEND_REQUEST_LENGTH else {
      throw ToxError.generic("Greeting too long")
    }

    var err = TOX_ERR_FRIEND_ADD_OK
    let friendID = try message.withCString { msgPtr in
      try address.withUnsafeBytes { bytes in
        guard let ptr = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
          throw ToxError.generic("Invalid address buffer")
        }
        return tox_friend_add(toxPointer, ptr,
                              msgPtr, message.utf8.count,
                              &err)
      }
    }

    if err != TOX_ERR_FRIEND_ADD_OK {
      throw ToxError.friendAddFailed(err)
    }
    return friendID
  }

  public func removeFriend(withID friendID: UInt32) throws {
    var errFriend = TOX_ERR_FRIEND_DELETE_OK
    tox_friend_delete(toxPointer, friendID, &errFriend)
    if errFriend != TOX_ERR_FRIEND_DELETE_OK { throw ToxError.friendRemoveFailed(errFriend) }
  }

  public func sendMessage(toFriend friendID: UInt32, text: String, type: MessageKind = .normal) async throws {
    try await withCheckedThrowingContinuation { cont in
      var errMsg = TOX_ERR_FRIEND_SEND_MESSAGE_OK
      _ = text.withCString { ptr in
        tox_friend_send_message(toxPointer, friendID, type.cValue, ptr, text.utf8.count, &errMsg)
      }
      errMsg == TOX_ERR_FRIEND_SEND_MESSAGE_OK ? cont.resume() : cont.resume(throwing: ToxError.messageSendFailed(errMsg))
    }
  }

  public func getFriendConnectionStatus(forID friendID: UInt32) -> ConnectionState {
    ConnectionState(cValue: tox_friend_get_connection_status(toxPointer, friendID, nil)) ?? .none
  }

  public func sendFile(toFriend friendID: UInt32, kind: FileKind, size: UInt64, fileName: String) throws -> UInt32 {
    var errFile = TOX_ERR_FILE_SEND_OK
    let fileID = fileName.withCString { ptr in
      tox_file_send(toxPointer, friendID, UInt32(kind.cValue), size, nil, ptr, fileName.utf8.count, &errFile)
    }
    if errFile != TOX_ERR_FILE_SEND_OK { throw ToxError.fileSendFailed(errFile) }
    return fileID
  }

  public func sendFileChunk(toFriend friendID: UInt32, fileID: UInt32, position: UInt64, data: Data) throws {
    var errChunk = TOX_ERR_FILE_SEND_CHUNK_OK
    try data.withUnsafeBytes { bytes in
      guard let base = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
        throw ToxError.generic("Invalid data buffer")
      }
      tox_file_send_chunk(toxPointer, friendID, fileID, position, base, data.count, &errChunk)
    }
    if errChunk != TOX_ERR_FILE_SEND_CHUNK_OK { throw ToxError.fileChunkFailed(errChunk) }
  }

  public func createConference() throws -> UInt32 {
    var errConf = TOX_ERR_CONFERENCE_NEW_OK
    let confID = tox_conference_new(toxPointer, &errConf)
    if errConf != TOX_ERR_CONFERENCE_NEW_OK { throw ToxError.generic("createConference failed: \(errConf)") }
    return confID
  }

  public func sendMessage(inConference conferenceID: UInt32, text: String, type: MessageKind = .normal) throws {
    try text.withCString { ptr in
      guard tox_conference_send_message(toxPointer, conferenceID, type.cValue, ptr, text.utf8.count, nil) else {
        throw ToxError.generic("sendMessageInConference failed")
      }
    }
  }

  public var incomingMessages: AsyncStream<IncomingMessage> {
    messageStream.stream
  }

  // MARK: – Цикл событий
  private func _eventLoop() async {
    let context = Unmanaged.passUnretained(self).toOpaque()
    while !Task.isCancelled {
      tox_iterate(toxPointer, context)
      let interval = tox_iteration_interval(toxPointer)
      try? await Task.sleep(for: .milliseconds(Int(interval)))
    }
  }

  // MARK: – Bootstrap helper
  private static func bootstrapNodes(_ nodes: [ToxNode], on tox: UnsafeMutablePointer<Tox>) throws {
    for node in nodes {
      // 1. Публичный ключ узла (hex‑строка → Data[32])
      guard let pkData = Data(hexString: node.publicKey), pkData.count == kPublicKeySize else {
        print("[Bootstrap] Некорректный публичный ключ: \(node.publicKey)")
        continue
      }

      // 2. IPv4
      pkData.withUnsafeBytes { pkPtr in
        var err = TOX_ERR_BOOTSTRAP_OK
        node.ipv4.withCString { addrPtr in
          tox_bootstrap(tox, addrPtr, node.port, pkPtr.baseAddress?.assumingMemoryBound(to: UInt8.self), &err)
          if err != TOX_ERR_BOOTSTRAP_OK {
            print("[Bootstrap] tox_bootstrap IPv4 failed (\(err)) for \(node.ipv4):\(node.port)")
          }
          err = TOX_ERR_BOOTSTRAP_OK // reset
          tox_add_tcp_relay(tox, addrPtr, node.port, pkPtr.baseAddress?.assumingMemoryBound(to: UInt8.self), &err)
          if err != TOX_ERR_BOOTSTRAP_OK {
            print("[Bootstrap] tox_add_tcp_relay IPv4 failed (\(err)) for \(node.ipv4):\(node.port)")
          }
        }
      }

      // 3. IPv6 (если есть)
      if let ipv6 = node.ipv6, !ipv6.isEmpty {
        pkData.withUnsafeBytes { pkPtr in
          var err = TOX_ERR_BOOTSTRAP_OK
          ipv6.withCString { addrPtr in
            tox_bootstrap(tox, addrPtr, node.port, pkPtr.baseAddress?.assumingMemoryBound(to: UInt8.self), &err)
            if err != TOX_ERR_BOOTSTRAP_OK {
              print("[Bootstrap] tox_bootstrap IPv6 failed (\(err)) for \(ipv6):\(node.port)")
            }
            err = TOX_ERR_BOOTSTRAP_OK
            tox_add_tcp_relay(tox, addrPtr, node.port, pkPtr.baseAddress?.assumingMemoryBound(to: UInt8.self), &err)
            if err != TOX_ERR_BOOTSTRAP_OK {
              print("[Bootstrap] tox_add_tcp_relay IPv6 failed (\(err)) for \(ipv6):\(node.port)")
            }
          }
        }
      }
    }
  }
}

// MARK: – Приватная реализация и вспомогательные объекты

/// Коробка для слабых ссылок на сервисы
private final class WeakBox {
  weak var service: ToxService?
  init(_ service: ToxService) { self.service = service }
}

/// Глобальный реестр активных сервисов по указателю
private var instances = [UnsafeMutableRawPointer: WeakBox]()

/// C‑callback для обработки входящих сообщений
private typealias FriendMessageCFunction = @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, TOX_MESSAGE_TYPE,
 UnsafePointer<UInt8>?, Int, UnsafeMutableRawPointer?) -> Void

private let friendMessageCallback: FriendMessageCFunction = { ptr, friendID, msgType, msgPtr, length, _ in
  guard
    let toxPtr = ptr,
    let box = instances[UnsafeMutableRawPointer(toxPtr)],
    let service = box.service,
    let msgPtr = msgPtr
  else { return }

  let buffer = UnsafeBufferPointer(start: msgPtr, count: length)
  if let text = String(bytes: buffer, encoding: .utf8) {
    let incoming = IncomingMessage(friendID: friendID, kind: msgType, text: text)
    Task { [weak service] in
      service?.messageStream.continuation.yield(incoming)
    }
  }
}

// friend request
private let friendRequestCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UnsafePointer<UInt8>?, UnsafePointer<UInt8>?, Int, UnsafeMutableRawPointer?) -> Void = { toxPtr, pkPtr, msgPtr, len, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service,
        let pkPtr,
        let msgPtr
  else { return }

  let pk  = Data(bytes: pkPtr, count: kPublicKeySize)
  let msg = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: msgPtr),
                   length: Int(len),
                   encoding: .utf8,
                   freeWhenDone: false) ?? ""
  Task { [weak svc] in
    svc?.friendEventStream.continuation.yield(.request(publicKey: pk, message: msg))
  }
}

// name change
private let friendNameCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, UnsafePointer<UInt8>?, Int, UnsafeMutableRawPointer?) -> Void = { toxPtr, fid, namePtr, len, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service,
        let namePtr
  else { return }

  let name = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: namePtr),
                    length: Int(len),
                    encoding: .utf8,
                    freeWhenDone: false) ?? ""
  Task { [weak svc] in
    svc?.friendEventStream.continuation.yield(.nameChanged(friendID: fid, name: name))
  }
}

// status‑msg change
private let friendStatusMsgCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, UnsafePointer<UInt8>?, Int, UnsafeMutableRawPointer?) -> Void = { toxPtr, fid, msgPtr, len, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service,
        let msgPtr
  else { return }

  let msg = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: msgPtr),
                   length: Int(len),
                   encoding: .utf8,
                   freeWhenDone: false) ?? ""
  Task { [weak svc] in
    svc?.friendEventStream.continuation.yield(.statusMessageChanged(friendID: fid, message: msg))
  }
}

// user‑status change
private let friendUserStatusCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, TOX_USER_STATUS, UnsafeMutableRawPointer?) -> Void = {
  toxPtr, fid, status, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service
  else { return }

  let st = UserStatus(rawValue: UInt8(status.rawValue)) ?? .none
  Task { [weak svc] in
    svc?.friendEventStream.continuation.yield(.userStatusChanged(friendID: fid,
                                                                 status: st))
  }
}

// connection‑status
private let friendConnStatusCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, TOX_CONNECTION, UnsafeMutableRawPointer?) -> Void = { toxPtr, fid, conn, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service
  else { return }

  let state = ConnectionState(cValue: conn) ?? .none
  Task { [weak svc] in
    svc?.friendEventStream.continuation.yield(.connectionStatusChanged(friendID: fid, state: state))
  }
}

// typing
private let friendTypingCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, Bool, UnsafeMutableRawPointer?) -> Void = { toxPtr, fid, isTyping, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service
  else { return }
  Task { [weak svc] in
    svc?.friendEventStream.continuation.yield(.typing(friendID: fid, isTyping: isTyping))
  }
}

// read‑receipt
private let friendReadReceiptCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, UInt32, UnsafeMutableRawPointer?) -> Void = { toxPtr, fid, msgID, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service
  else { return }
  Task { [weak svc] in
    svc?.friendEventStream.continuation.yield(.readReceipt(friendID: fid, messageID: msgID))
  }
}

// lossy / lossless packets
private let friendLossyPktCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, UnsafePointer<UInt8>?, Int, UnsafeMutableRawPointer?) -> Void = { toxPtr, fid, dataPtr, len, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service,
        let dataPtr
  else { return }

  let d = Data(bytes: dataPtr, count: Int(len))
  Task { [weak svc] in
    svc?.friendEventStream.continuation.yield(.lossyPacket(friendID: fid, data: d))
  }
}

private let friendLosslessPktCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, UnsafePointer<UInt8>?, Int, UnsafeMutableRawPointer?) -> Void = { toxPtr, fid, dataPtr, len, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service,
        let dataPtr
  else { return }

  let d = Data(bytes: dataPtr, count: Int(len))
  Task { [weak svc] in
    svc?.friendEventStream.continuation.yield(.losslessPacket(friendID: fid, data: d))
  }
}

// запрос чанка
private let fileChunkRequestCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, UInt32,
 UInt64, Int, UnsafeMutableRawPointer?) -> Void = { toxPtr, fid, fileNum,
  pos, len, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service
  else { return }

  Task { [weak svc] in
    svc?.fileEventStream.continuation.yield(
      .chunkRequest(friendID: fid,
                    fileID: fileNum,
                    position: pos,
                    length: UInt32(len))   // при необходимости приводим
    )
  }
}

// приём чанка (file_recv_chunk)
private let fileRecvChunkCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, UInt32,
 UInt64, UnsafePointer<UInt8>?, Int,          // ← Int !
 UnsafeMutableRawPointer?) -> Void = { toxPtr, fid, fileNum,
  pos, dataPtr, len, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service,
        let dataPtr
  else { return }

  let chunk = Data(bytes: dataPtr, count: len)

  Task { [weak svc] in
    svc?.fileEventStream.continuation.yield(
      .chunk(friendID: fid,
             fileID: fileNum,
             position: pos,
             data: chunk)
    )
  }
}

// file_recv_control – 4 аргумента
private let fileRecvControlCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, UInt32,
 TOX_FILE_CONTROL, UnsafeMutableRawPointer?) -> Void = { toxPtr, fid, fileID,
  ctrl, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service
  else { return }

  Task { [weak svc] in
    svc?.fileEventStream.continuation.yield(
      .stateChanged(friendID: fid,
                    fileID: fileID,
                    control: FileControl(rawValue: UInt8(ctrl.rawValue)) ?? .kill)
    )
  }
}

// входящая заявка на файл (file_recv)
private let fileRecvCallback: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, UInt32,
 UInt32, UInt64,
 UnsafePointer<UInt8>?, Int,
 UnsafeMutableRawPointer?) -> Void = { toxPtr, fid, fileNum,
  kind, size,
  namePtr, len, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service
  else { return }

  let fileName = utf8String(namePtr, len)

  Task { [weak svc] in
    svc?.fileEventStream.continuation.yield(
      .incomingRequest(friendID: fid,
                       fileID: fileNum,
                       kind: FileKind(rawValue: kind) ?? .data,
                       size: size,
                       fileName: fileName)
    )
  }
}

private let conferenceInviteCb:
(@convention(c) (UnsafeMutablePointer<Tox>?,   // tox instance
                 UInt32,                       // friendID
                 TOX_CONFERENCE_TYPE,          // type (audio/video или text)
                 UnsafePointer<UInt8>?,        // cookie
                 Int,                          // length
                 UnsafeMutableRawPointer?) -> Void)? = { toxPtr, fid, _, cookiePtr, len, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service,
        let cookiePtr
  else { return }

  let cookie = Data(bytes: cookiePtr, count: len)
  Task { [weak svc] in
    svc?.conferenceEventStream.continuation
      .yield(.invited(friendID: fid, cookie: cookie))
  }
}

private let conferenceConnectedCb: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32,
 UnsafeMutableRawPointer?) -> Void = { toxPtr, confID, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service
  else { return }

  Task { [weak svc] in
    svc?.conferenceEventStream.continuation
      .yield(.connected(conferenceID: confID))
  }
}

private let conferenceMessageCb: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, UInt32,
 TOX_MESSAGE_TYPE,
 UnsafePointer<UInt8>?, Int,
 UnsafeMutableRawPointer?) -> Void = { toxPtr, confID, peerID,
  msgType, msgPtr, len, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service,
        let msgPtr
  else { return }

  let text = utf8String(msgPtr, len)
  Task { [weak svc] in
    svc?.conferenceEventStream.continuation
      .yield(.message(conferenceID: confID,
                      peerID: peerID,
                      kind: MessageKind(cValue: msgType) ?? .normal,
                      text: text))
  }
}

private let conferenceTitleCb:
(@convention(c) (UnsafeMutablePointer<Tox>?,   // tox
                 UInt32,                       // conferenceID
                 UInt32,                       // peerID
                 UnsafePointer<UInt8>?,        // title ptr
                 Int,                          // length (size_t)
                 UnsafeMutableRawPointer?) -> Void)? = { toxPtr, confID, peerID,
  titlePtr, len, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service,
        let titlePtr
  else { return }

  let title = utf8String(titlePtr, len)
  Task { [weak svc] in
    svc?.conferenceEventStream.continuation
      .yield(.titleChanged(conferenceID: confID, title: title))
  }
}

private let conferencePeerNameCb: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32, UInt32,
 UnsafePointer<UInt8>?, Int,
 UnsafeMutableRawPointer?) -> Void = { toxPtr, confID, peerID,
  namePtr, len, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service,
        let namePtr
  else { return }

  let name = utf8String(namePtr, len)
  Task { [weak svc] in
    svc?.conferenceEventStream.continuation
      .yield(.peerNameChanged(conferenceID: confID,
                              peerID: peerID,
                              name: name))
  }
}

private let conferencePeerListChangedCb: @convention(c)
(UnsafeMutablePointer<Tox>?, UInt32,
 UnsafeMutableRawPointer?) -> Void = { toxPtr, confID, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc  = box.service
  else { return }

  Task { [weak svc] in
    svc?.conferenceEventStream.continuation
      .yield(.peerListChanged(conferenceID: confID))
  }
}

/// C-callback от toxcore о смене нашего соединения с сетью
private let selfConnectionStatusCallback: @convention(c)
(UnsafeMutablePointer<Tox>?,          // tox instance
 TOX_CONNECTION,                      // новое состояние
 UnsafeMutableRawPointer?) -> Void = { toxPtr, conn, _ in
  guard let toxPtr,
        let box = instances[UnsafeMutableRawPointer(toxPtr)],
        let svc = box.service
  else { return }

  let state = ConnectionState(cValue: conn) ?? .none
  Task { [weak svc] in
    svc?.selfConnectionStream.continuation.yield(state)
  }
}

// MARK: – Постоянное логирование toxcore → Xcode‑console

/// Печатает все сообщения toxcore без фильтра уровней.
private let consoleLogCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?, Tox_Log_Level,
  UnsafePointer<Int8>?, UInt32,
  UnsafePointer<Int8>?, UnsafePointer<Int8>?,
  UnsafeMutableRawPointer?
) -> Void = { _, lvl, filePtr, line, funcPtr, msgPtr, _ in
  guard let msgPtr else { return }

  // Получаем текст уровня из toxcore
  let levelStr = String(cString: tox_log_level_to_string(lvl))

  // file / func могут отсутствовать → подставляем заглушку
  let file = filePtr.map { String(cString: $0) } ?? "<file>"
  let fn   = funcPtr.map { String(cString: $0) } ?? "<fn>"
  let msg  = String(cString: msgPtr)
  print("[Tox][\(levelStr)] \(file):\(line) \(fn) – \(msg)")
}

// MARK: – Bridge Swift → C опций
private func withUnsafeBridgeOptions(_ options: ToxServiceOptions) -> (
  Tox_Options,
  UnsafeMutablePointer<Int8>?,   // proxyDup
  UnsafeMutablePointer<UInt8>?   // savedataDup
) {
  var cOpts = Tox_Options()
  tox_options_default(&cOpts)

  // ───────── пункт 8: локальное обнаружение и DHT ─────────
  tox_options_set_local_discovery_enabled(
    &cOpts,
    options.isLocalDiscoveryEnabled
  )
  tox_options_set_dht_announcements_enabled(
    &cOpts,
    options.isDHTAnnouncementsEnabled
  )

  // ───────── Базовые флаги ─────────
  cOpts.ipv6_enabled = options.isIPv6Enabled
  cOpts.udp_enabled  = options.isUDPEnabled
  cOpts.start_port   = options.startPort
  cOpts.end_port     = options.endPort
  cOpts.tcp_port     = options.tcpPort

  // ───────── Proxy ─────────
  var dupHost: UnsafeMutablePointer<Int8>? = nil
  if options.proxyType != .none, !options.proxyHost.isEmpty {
    dupHost                    = strdup(options.proxyHost)
    cOpts.proxy_type           = options.cProxyType
    cOpts.proxy_host           = UnsafePointer(dupHost!)
    cOpts.proxy_port           = options.proxyPort
  } else {
    cOpts.proxy_type           = TOX_PROXY_TYPE_NONE
    cOpts.proxy_host           = nil
    cOpts.proxy_port           = 0
  }

  // ───────── Savedata ─────────
  var dupSavedata: UnsafeMutablePointer<UInt8>? = nil
  if let sd = options.savedata, !sd.isEmpty {
    dupSavedata                = .allocate(capacity: sd.count)
    _ = sd.copyBytes(to: UnsafeMutableBufferPointer(start: dupSavedata!,
                                                    count: sd.count))
    cOpts.savedata_type        = options.cSavedataType
    cOpts.savedata_data        = UnsafePointer(dupSavedata!)
    cOpts.savedata_length      = sd.count
  } else {
    cOpts.savedata_type        = TOX_SAVEDATA_TYPE_NONE
    cOpts.savedata_data        = nil
    cOpts.savedata_length      = 0
  }

  // ───────── Логирование всегда включено ─────────
  tox_options_set_log_callback(&cOpts, consoleLogCallback)
  tox_options_set_log_user_data(&cOpts, nil)
  return (cOpts, dupHost, dupSavedata)
}

// MARK: – Утилиты
private extension Data {
  /// init из 76-символьной hex-строки адреса (возвращает 38 raw-байт)
  init?(toxAddressHex: String) {
    let clean = toxAddressHex.lowercased()
    guard clean.count == 76 else { return nil }

    var data = Data(capacity: 38)
    var idx = clean.startIndex
    for _ in 0..<38 {
      let next = clean.index(idx, offsetBy: 2)
      guard let byte = UInt8(clean[idx..<next], radix: 16) else { return nil }
      data.append(byte)
      idx = next
    }
    self = data
  }

  /// hex-строка в нижнем регистре
  var hex: String { map { String(format: "%02x", $0) }.joined() }

  /// Инициализирует `Data` из hex‑строки (в любом регистре, без пробелов).
  init?(hexString: String) {
    let cleaned = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
    guard cleaned.count % 2 == 0 else { return nil }
    var bytes = [UInt8]()
    bytes.reserveCapacity(cleaned.count / 2)
    var index = cleaned.startIndex
    while index < cleaned.endIndex {
      let nextIndex = cleaned.index(index, offsetBy: 2)
      let byteString = cleaned[index..<nextIndex]
      guard let byte = UInt8(byteString, radix: 16) else { return nil }
      bytes.append(byte)
      index = nextIndex
    }
    self = Data(bytes)
  }
}

/// Быстрое и безопасное преобразование (без options, без Foundation copies).
@inline(__always)
private func utf8String(_ ptr: UnsafePointer<UInt8>?, _ len: Int) -> String {
  guard let ptr, len > 0 else { return "" }
  return String(
    decoding: UnsafeBufferPointer(start: ptr, count: len),
    as: UTF8.self
  )
}

// Константы размеров буферов
private let kPublicKeySize = 32
private let kAddressSize   = 38
private let kSecretKeySize = Int(tox_secret_key_size())
