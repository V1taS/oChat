//
//  ToxManager.swift
//  oChat
//
//  Created by Vitalii Sosin on 9.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import Combine
import Foundation
import ToxSwift

/// Глобальный менеджер, который инкапсулирует работу с ToxService.
@MainActor
final class ToxManager: ObservableObject {

  // MARK: - Singleton
  static let shared = ToxManager()

  // MARK: - Внутренние поля

  /// Реальный сервис, реализующий ToxServiceProtocol (ваша обёртка над C-кодом toxcore).
  var toxService: ToxServiceProtocol!
  private let cryptoService = CryptoService.shared
  private let zipArchiveService = ZipArchiveService.shared
  private let fileManagerService = FileManagerService.shared

  /// Пул тасков для обработки бесконечных AsyncStream.
  private var tasks = Set<Task<Void, Never>>()

  // MARK: - Публикуемые свойства (отражение состояния в UI)

  /// Входящий запрос «добавь в друзья».
  @Published var friendRequests: [FriendRequest] = []

  /// Список друзей (их ID, имя, статус и т.д.).
  @Published var friends: [FriendModel] = FriendModel.mockList()

  /// Все входящие/исходящие сообщения (в реальном приложении можно хранить раздельно по чатам).
  @Published var messages: [UInt32: [ChatMessage]] = [
    1: ChatMessage.mockList(friendID: 1),
    2: ChatMessage.mockList(friendID: 2),
    3: ChatMessage.mockList(friendID: 3)
  ]

  /// Активные/известные конференции.
  @Published var conferences: [ConferenceModel] = []

  /// Список входящих/исходящих файлов (для трекинга прогресса).
  @Published var fileTransfers: [FileTransferModel] = []

  /// Состояние звонков (например, активные звонки по friendID).
  @Published var activeCalls: [UInt32: CallState] = [:]

  /// Статус подключения к DHT (для UI)
  @Published var connectionState: ConnectionStatus = .offline

  @AppStorage("toxSavedata")
  private var toxSavedataBase64: String = ""

  // MARK: - Bindings helpers

  // === ДРУЗЬЯ ================================================================
  func bindingForFriend(_ friend: FriendModel) -> Binding<FriendModel>? {
    guard let index = friends.firstIndex(of: friend) else { return nil }
    return Binding(
      get: { self.friends[index] },
      set: { self.friends[index] = $0 }
    )
  }

  // === ЗАПРОСЫ В ДРУЗЬЯ ======================================================
  func bindingForFriendRequest(_ request: FriendRequest) -> Binding<FriendRequest>? {
    guard let index = friendRequests.firstIndex(of: request) else { return nil }
    return Binding(
      get: { self.friendRequests[index] },
      set: { self.friendRequests[index] = $0 }
    )
  }

  // === КОНФЕРЕНЦИИ ===========================================================
  func bindingForConference(_ conf: ConferenceModel) -> Binding<ConferenceModel>? {
    guard let index = conferences.firstIndex(of: conf) else { return nil }
    return Binding(
      get: { self.conferences[index] },
      set: { self.conferences[index] = $0 }
    )
  }

  // === ПЕРЕДАЧИ ФАЙЛОВ =======================================================
  func bindingForFileTransfer(_ transfer: FileTransferModel) -> Binding<FileTransferModel>? {
    guard let index = fileTransfers.firstIndex(of: transfer) else { return nil }
    return Binding(
      get: { self.fileTransfers[index] },
      set: { self.fileTransfers[index] = $0 }
    )
  }

  // === СООБЩЕНИЯ (словарь) ===================================================
  /// Binding ко всему массиву сообщений с конкретным другом.
  func bindingForMessages(friendId: UInt32) -> Binding<[ChatMessage]> {
    Binding(
      get: { self.messages[friendId, default: []] },
      set: { self.messages[friendId] = $0 }
    )
  }

  // === ОДНО СООБЩЕНИЕ ==========================================================
  func bindingForMessage(friendId: UInt32,
                         message: ChatMessage) -> Binding<ChatMessage>? {
    guard let friendMsgs = messages[friendId],
          let index = friendMsgs.firstIndex(of: message) else {
      return nil
    }
    return Binding(
      get: { self.messages[friendId]![index] },
      set: { self.messages[friendId]![index] = $0 }
    )
  }

  // === СОСТОЯНИЕ ЗВОНКА (словарь) ============================================
  func bindingForCallState(friendId: UInt32) -> Binding<CallState>? {
    guard activeCalls[friendId] != nil else { return nil }
    return Binding(
      get: { self.activeCalls[friendId]! },
      set: { self.activeCalls[friendId] = $0 }
    )
  }

  // MARK: - Инициализация

  private init() {
    startToxService()
  }

  // MARK: - Жизненный цикл Tox-ядра

  func startToxService() {
    connectionState = .inProgress
    do {
      let bootstrapNodes = try JSONLoader.load([ToxNode].self, fromFile: "bootstrapNodes")
      var toxServiceOptions = ToxServiceOptions()

      // NEW: восстановление, если есть сохранённые данные
      if let saved = Data(base64Encoded: toxSavedataBase64), !saved.isEmpty {
        toxServiceOptions.savedataType = .toxSave
        toxServiceOptions.savedata = saved
        print("🔄 Восстанавливаем Tox-сессию (\(saved.count) B)")
      }

      self.toxService = try ToxService(options: toxServiceOptions, bootstrapNodes: bootstrapNodes)
    } catch {
      fatalError("Не удалось инициализировать ToxService: \(error)")
    }

    // Подключаемся к потокам событий
    observeStreams()

    // Начальное заполнение: загрузим список друзей и конференций
    Task {
      await refreshFriendsList()
      await refreshConferencesList()
    }
  }

  /// Корректно останавливает ядро и отменяет все подписки.
  /// Вызывайте, когда приложение уходит в background / закрывается.
  func shutdown() async {
    connectionState = .offline
    // 3. Отключаемся от сети и освобождаем ресурсы toxcore
    await toxService.shutdown()
    print("🚨 Остановка Tox-ядра")
  }

  /// Полный рестарт ядра с сохранением профиля.
  /// Вызывайте при возврате в foreground или при выявленной потере связи.
  func restart() async throws {
    connectionState = .inProgress
    do {
      // 3. Перезапускаем ядро внутри ToxService
      try await toxService.restart()

      // 5. Обновляем локальные модели, чтобы UI отразил новое состояние
      await refreshFriendsList()
      await refreshConferencesList()

      print("🔄 Tox-ядро успешно перезапущено")
    } catch {
      print("❌ Ошибка рестарта ToxService: \(error)")
      throw error
    }
  }

  // MARK: - Подписка на события (AsyncStream)

  private func observeStreams() {
    // 1. События сообщений
    let msgTask = Task {
      for await incoming in await toxService.incomingMessages {
        await handleIncomingMessage(incoming)
      }
    }

    // 2. События по файлам
    let fileTask = Task {
      for await fileEvent in await toxService.fileEvents {
        handleFileEvent(fileEvent)
      }
    }

    // 3. События звонков
    let callTask = Task {
      for await callEvent in await toxService.callEvents {
        handleCallEvent(callEvent)
      }
    }

    // 4. События друзей
    let friendTask = Task {
      for await friendEvent in await toxService.friendEvents {
        await handleFriendEvent(friendEvent)
      }
    }

    // 5. События конференций
    let confTask = Task {
      for await conferenceEvent in await toxService.conferenceEvents {
        handleConferenceEvent(conferenceEvent)
      }
    }

    // 6. Статус DHT-подключения
    let dhtTask = Task {
      for await connectionState in await toxService.connectionStatusEvents {
        handleDHTConnectionState(connectionState)
      }
    }

    tasks = [msgTask, fileTask, callTask, friendTask, confTask, dhtTask]
  }

  // MARK: - Обработчики событий

  private func handleIncomingMessage(_ incoming: IncomingMessage) async {
    guard let jsonData = incoming.text.data(using: .utf8),
          let model = try? JSONDecoder().decode(MessengerNetworkRequestModel.self, from: jsonData) else {
      return
    }

    let toxAddressDecrypt = cryptoService.decrypt(model.toxAddress)
    guard let idx = friends.firstIndex(where: { $0.id == incoming.friendID }) else { return }
    let pushNotificationTokenDecrypt = cryptoService.decrypt(model.pushNotificationToken)
    friends[idx].pushNotificationToken = pushNotificationTokenDecrypt
    friends[idx].address = toxAddressDecrypt
    guard let messageTextDecrypt = cryptoService.decrypt(model.messageText) else { return }

    let newMessage = ChatMessage(
      messageId: nil,
      friendID: incoming.friendID,
      message: messageTextDecrypt,
      replyMessageText: nil,
      reactions: nil,
      messageType: .incoming,
      date: Date(),
      messageStatus: .sent,
      attachments: []
    )
    messages[incoming.friendID]?.append(newMessage)
    persistState()
  }

  private func handleFileEvent(_ event: FileEvent) {
    switch event {
    case let .incomingRequest(friendID, fileID, kind, size, fileName):
      // Создадим модель "входящего файла" и добавим в список
      let transfer = FileTransferModel(
        friendID: friendID,
        fileID: fileID,
        fileName: fileName,
        fileSize: size,
        progress: 0.0,
        status: .incoming,
        fileData: Data() // 🚨 Не знаю что тут делать
      )
      fileTransfers.append(transfer)

    case let .chunkRequest(friendID, fileID, position, length):
      // Друг просит у нас кусок файла - здесь можем вычитать нужный кусок из файла и отправить
      Task {
        // Пример: берём данные из локального хранилища (пустой Data для примера)
        let dataToSend = Data()
        do {
          try await toxService.sendFileChunk(
            toFriend: friendID,
            fileID: fileID,
            position: position,
            data: dataToSend
          )
        } catch {
          print("Не удалось отправить кусок файла: \(error)")
        }
      }

    case let .chunk(friendID, fileID, position, data):
      // Мы получили кусок файла от друга
      // Можно сохранить куда-то (например, на диск).
      // Также можно обновить progress, если знаем общий размер.
      if let idx = fileTransfers.firstIndex(where: { $0.fileID == fileID && $0.friendID == friendID }) {
        // Допустим, условно увеличиваем "прогресс" на размер chunk
        fileTransfers[idx].progress += Double(data.count)
      }

    case let .stateChanged(friendID, fileID, control):
      // Изменение состояния (пауза, отмена, и т.д.)
      if let idx = fileTransfers.firstIndex(where: { $0.fileID == fileID && $0.friendID == friendID }) {
        switch control {
        case .pause:
          fileTransfers[idx].status = .paused
        case .resume:
          fileTransfers[idx].status = .inProgress
        case .cancel, .kill:
          fileTransfers[idx].status = .cancelled
        }
      }
    }
  }

  private func handleCallEvent(_ event: CallEvent) {
    switch event {
    case let .call(friendID, audioEnabled, videoEnabled):
      // У друга либо начался вызов, либо статус поменялся
      activeCalls[friendID] = CallState(
        audioEnabled: audioEnabled,
        videoEnabled: videoEnabled
      )

    case let .audioFrame(friendID, sampleCount, channels, sampleRate, data):
      // Получили PCM-аудио - можно прокинуть в аудио-рендер
      print("Аудио-фрейм от \(friendID), \(sampleCount) семплов, \(channels) канал(а), rate=\(sampleRate)")

    case let .videoFrame(friendID, width, height, y, u, v, yStride, uStride, vStride):
      // Получили видео-фрейм YUV420 - можно отобразить через Metal/SwiftUI/AVFoundation
      print("Видео-фрейм от \(friendID), размер \(width)x\(height)")
    }
  }

  private func handleFriendEvent(_ event: FriendEvent) async {
    switch event {
    case let .request(publicKey, message):
      guard let jsonData = message.data(using: .utf8),
            let model = try? JSONDecoder().decode(MessengerNetworkRequestModel.self, from: jsonData) else {
        return
      }
      let friendRequest = FriendRequest(
        publicKey: publicKey,
        meshAddress: nil,
        toxAddress: nil,
        publicKeyForEncryption: model.publicKeyForEncryption,
        pushNotificationToken: nil,
        chatRules: model.chatRules
      )
      friendRequests.append(friendRequest)

    case let .connectionStatusChanged(friendID, state):
      guard let idx = friends.firstIndex(where: { $0.id == friendID }) else { return }
      switch state {
      case .none:
        friends[idx].connectionState = .offline
      case .tcp:
        friends[idx].connectionState = .online
      case .udp:
        friends[idx].connectionState = .online
      }

    case let .typing(friendID, isTyping):
      guard let idx = friends.firstIndex(where: { $0.id == friendID }) else { return }
      friends[idx].isTyping = isTyping
      print("Друг \(friendID) typing = \(isTyping)")

    case let .readReceipt(friendID, messageID):
      // Удобно отмечать, что сообщение прочитано

      guard let idx = messages[friendID]?.firstIndex(where: { $0.messageId == messageID }) else { return }
      messages[friendID]?[idx].messageStatus = .read
      print("Друг \(friendID) прочитал сообщение \(messageID)")

    case .lossyPacket: break
    case .losslessPacket: break
    case .nameChanged: break
    case .statusMessageChanged: break
    case .userStatusChanged: break
    }
  }

  private func handleConferenceEvent(_ event: ConferenceEvent) {
    switch event {
    case let .invited(friendID, cookie):
      // Нас пригласили в конференцию
      print("Приглашение в конференцию от друга \(friendID). Cookie = \(cookie)")

    case let .connected(conferenceID):
      // Успешное подключение к конференции
      print("Подключились к конференции \(conferenceID)")
      Task {
        await refreshConferencesList()
      }

    case let .message(conferenceID, peerID, kind, text):
      // Групповое сообщение
      print("Конф. \(conferenceID): Сообщение от \(peerID) => \(text)")

    case let .titleChanged(conferenceID, title):
      if let idx = conferences.firstIndex(where: { $0.id == conferenceID }) {
        conferences[idx].title = title
      }

    case let .peerNameChanged(conferenceID, peerID, name):
      print("Конф. \(conferenceID): peer \(peerID) сменил имя на \(name)")

    case let .peerListChanged(conferenceID):
      print("Конф. \(conferenceID): состав участников изменился")
    }
  }

  // MARK: - Обработчик статуса DHT

  private func handleDHTConnectionState(_ state: ToxConnectionState) {
    // Сохраняем в @Published-свойство, чтобы UI мог реагировать
    switch state {
    case .none:
      connectionState = .offline
    case .tcp:
      connectionState = .online
    case .udp:
      connectionState = .online
    }

    print("Изменился статус DHT-подключения: \(state)")
    Task {
      print("OwnAddress: \(await getOwnAddress())")
    }
  }

  // MARK: - Методы для обновления локальных списков

  func refreshFriendsList() async { // 🚨 Подумать как сделать
    //    let friendIDs = await toxService.friendList()
    //    var updatedFriends: [FriendModel] = []
    //
    //    for friendID in friendIDs {
    //      let name = await toxService.getFriendName(friendID)
    //      let connectionState = await toxService.getFriendConnectionStatus(forID: friendID)
    //
    //      let model = FriendModel(
    //        id: friendID,
    //        address: T##String,
    //        meshAddress: T##String?,
    //        encryptionPublicKey: T##String?,
    //        pushNotificationToken: T##String?,
    //        contactEmoji: T##String?,
    //        connectionState: T##ConnectionStatus,
    //        isTyping: T##Bool,
    //        unreadCount: T##Int
    //      )
    //
    //      let model = FriendModel(
    //        id: friendID,
    //        name: name,
    //        statusMessage: statusMessage,
    //        userStatus: userStatus,
    //        connectionState: connectionState
    //      )
    //      updatedFriends.append(model)
    //    }
    //
    //    self.friends = updatedFriends
  }

  func refreshConferencesList() async {
    let confIDs = await toxService.conferenceList()
    var updatedConfs: [ConferenceModel] = []

    for cid in confIDs {
      let title = await toxService.getConferenceTitle(cid)
      let type = await toxService.getConferenceType(cid)

      let model = ConferenceModel(
        id: cid,
        title: title,
        type: type
      )
      updatedConfs.append(model)
    }

    self.conferences = updatedConfs
  }

  // MARK: - Публичные методы для View (добавление друзей, сообщений и т.д.)

  public func acceptFriendRequest(friendRequest: FriendRequest) async {
    // Кто-то стучится к нам. Можно решить: автоматически добавить или спросить у пользователя
    do {
      let friendID = try await toxService.acceptFriendRequest(publicKey: friendRequest.publicKey)
      print("✅ Приняли запрос; friendID = \(friendID)")
      let friend = FriendModel(
        id: friendID,
        address: "",
        meshAddress: nil,
        encryptionPublicKey: friendRequest.publicKeyForEncryption,
        pushNotificationToken: nil,
        avatar: .init(),
        connectionState: .online,
        isTyping: false,
        unreadCount: .zero,
        chatRules: friendRequest.chatRules
      )

      friends.append(friend)
    } catch {
      print("❌ Не удалось принять запрос: \(error)")
    }
  }

  /// Отправить сообщение конкретному другу.
  func sendMessage(to friendID: UInt32, text: String) async {
    guard let idx = friends.firstIndex(where: { $0.id == friendID }) else { return }
    guard let encryptionPublicKey = friends[idx].encryptionPublicKey else { return }

    let messageTextEncrypt = cryptoService.encrypt(text, publicKey: encryptionPublicKey)
    let pushNotificationTokenEncrypt = cryptoService.encrypt(Secrets.pushNotificationToken, publicKey: encryptionPublicKey)
    let toxAddressEncrypt = await cryptoService.encrypt(getOwnAddress(), publicKey: encryptionPublicKey)

    let model = MessengerNetworkRequestModel(
      messageID: UUID().uuidString,
      messageText: messageTextEncrypt,
      replyMessageText: nil,
      reactions: nil,
      attachments: nil,
      meshAddress: nil,
      toxAddress: toxAddressEncrypt,
      publicKeyForEncryption: cryptoService.publicKey(),
      pushNotificationToken: pushNotificationTokenEncrypt,
      chatRules: friends[idx].chatRules
    )
    guard let json = createJSONString(from: model), let jsonData = json.data(using: .utf8) else { return }

    // счётчик байтов
    if jsonData.count > 1_300 {
      // JSON слишком большой текст, отправляем как файл
      await sendFile(to: friendID, messageText: text, attachments: [])
      return
    }

    do {
      let messageId = try await toxService.sendMessage(
        toFriend: friendID,
        text: json
      )
      // Сохраним и в локальный массив (как исходящее)
      let outgoing = ChatMessage(
        messageId: messageId,
        friendID: friendID,
        message: text,
        replyMessageText: nil,
        reactions: nil,
        messageType: .outgoing,
        date: Date(),
        messageStatus: .sent,
        attachments: nil
      )
      messages[friendID]?.append(outgoing)
      persistState()
    } catch {
      print("Ошибка отправки сообщения другу \(friendID): \(error)")
    }
  }

  /// Принимает **только** 76-символьный адрес. (Если нужен PK-hex – отдельный метод.)
  func addFriend(addressHex: String, greeting: String) {
    Task { @MainActor in
      let cleaned = addressHex
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "-", with: "")
        .lowercased()

      guard let addrData = Data(hexString: cleaned) else {
        print("❌ Tox-адрес должен быть 76 hex-символов"); return
      }

      do {
        let id = try await toxService.addFriend(withAddress: addrData, greeting: greeting)
        print("✅ friendID = \(id)")
        await refreshFriendsList()
        persistState()
      } catch {
        print("❌ Не удалось добавить: \(error)")
      }
    }
  }

  /// Удалить друга по ID.
  func removeFriend(_ friendID: UInt32) {
    Task {
      do {
        try await toxService.removeFriend(withID: friendID)
        await refreshFriendsList()
      } catch {
        print("Не удалось удалить друга: \(error)")
      }
    }
  }

  /// Начать аудио-звонок (без видео).
  func startAudioCall(with friendID: UInt32) {
    Task {
      do {
        try await toxService.startCall(
          friendID: friendID,
          audioBitRate: 48_000,
          videoBitRate: 0
        )
        print("Звонок начат")
      } catch {
        print("Ошибка при старте звонка: \(error)")
      }
    }
  }

  /// Ответить на входящий звонок.
  func answerCall(from friendID: UInt32) {
    Task {
      do {
        try await toxService.answerCall(
          friendID: friendID,
          audioBitRate: 48_000,
          videoBitRate: 0
        )
        print("Звонок принят")
      } catch {
        print("Ошибка при принятии звонка: \(error)")
      }
    }
  }

  /// Завершить (или отменить) звонок.
  func hangupCall(with friendID: UInt32) {
    Task {
      do {
        try await toxService.controlCall(
          friendID: friendID,
          control: .cancel
        )
      } catch {
        print("Ошибка при завершении звонка: \(error)")
      }
    }
  }

  /// Создать новую конференцию.
  func createConference() {
    Task {
      do {
        let newConfID = try await toxService.createConference()
        print("Создана конференция #\(newConfID)")
        await refreshConferencesList()
      } catch {
        print("Не удалось создать конференцию: \(error)")
      }
    }
  }

  /// Отправить сообщение в конференцию.
  func sendMessage(inConference confID: UInt32, text: String) {
    Task {
      do {
        try await toxService.sendMessage(
          inConference: confID,
          text: text,
          type: .normal
        )
      } catch {
        print("Ошибка отправки сообщения в конфу \(confID): \(error)")
      }
    }
  }

  /// Пригласить друга в конференцию.
  func inviteToConference(friendID: UInt32, confID: UInt32) {
    Task {
      do {
        try await toxService.inviteToConference(
          friendID: friendID,
          conferenceID: confID
        )
      } catch {
        print("Ошибка приглашения друга \(friendID) в конфу \(confID): \(error)")
      }
    }
  }

  /// Покинуть конференцию с опциональным прощальным сообщением.
  func leaveConference(confID: UInt32, goodbyeText: String = "Пока!") {
    Task {
      do {
        try await toxService.leaveConference(confID, partingMessage: goodbyeText)
        await refreshConferencesList()
      } catch {
        print("Ошибка при выходе из конференции \(confID): \(error)")
      }
    }
  }

  /// Отправить (запушить) файл другу целиком.
  func sendFile(
    to friendID: UInt32,
    messageText: String?,
    attachments: [MediaAttachmentURL]
  ) async {
    guard let idx = friends.firstIndex(where: { $0.id == friendID }) else { return }
    guard let encryptionPublicKey = friends[idx].encryptionPublicKey else { return }
    do {
      let valid = attachments.compactMap { $0 }
      var mapped = [MediaAttachmentData]()
      mapped.reserveCapacity(valid.count)
      for attachment in valid {
        mapped.append(try await attachment.mapToData())
      }

      var messageTextEncrypt: String?
      if let messageText {
        messageTextEncrypt = cryptoService.encrypt(messageText, publicKey: encryptionPublicKey)
      }
      let pushNotificationTokenEncrypt = cryptoService.encrypt(Secrets.pushNotificationToken, publicKey: encryptionPublicKey)
      let toxAddressEncrypt = await cryptoService.encrypt(getOwnAddress(), publicKey: encryptionPublicKey)

      let model = MessengerNetworkRequestModel(
        messageID: UUID().uuidString,
        messageText: messageTextEncrypt,
        replyMessageText: nil,
        reactions: nil,
        attachments: mapped,
        meshAddress: nil,
        toxAddress: toxAddressEncrypt,
        publicKeyForEncryption: cryptoService.publicKey(),
        pushNotificationToken: pushNotificationTokenEncrypt,
        chatRules: friends[idx].chatRules
      )
      guard let json = createJSONString(from: model), let jsonData = json.data(using: .utf8) else { return }

      let password = cryptoService.generatePassword(length: 30)
      let passwordEncrypt = cryptoService.encrypt(password, publicKey: encryptionPublicKey)
      guard let passwordEncrypt,
            let passwordEncodedString = passwordEncrypt.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
        return
      }
      let zipFileURL = try await zipArchiveService.zipFiles(
        files: [(name: UUID().uuidString, data: jsonData)],
        archiveName: passwordEncodedString,
        password: password
      )

      let fileSize = UInt64(jsonData.count)
      let zipFile = try Data(contentsOf: zipFileURL)
      let fileName = UUID().uuidString

      let fileID = try await toxService.sendFile(
        toFriend: friendID,
        size: fileSize,
        fileName: fileName
      )

      // Добавляем в локальный список, чтобы трекать
      let transfer = FileTransferModel(
        friendID: friendID,
        fileID: fileID,
        fileName: fileName,
        fileSize: fileSize,
        progress: 0,
        status: .inProgress,
        fileData: zipFile
      )
      fileTransfers.append(transfer)

      // Ждём, когда друг запросит chunk-и (или используем другую логику)
    } catch {
      print("Ошибка при отправке файла: \(error)")
    }
  }

  // MARK: - Дополнительные методы из протокола

  func getOwnAddress() async -> String {
    await toxService.getOwnAddress()
  }

  func getOwnPublicKey() async -> Data {
    await toxService.getOwnPublicKey()
  }

  func getOwnSecretKey() async -> Data {
    await toxService.getOwnSecretKey()
  }

  func setDisplayName(_ name: String) {
    Task {
      do {
        try await toxService.setDisplayName(name)
      } catch {
        print("Не удалось установить имя: \(error)")
      }
    }
  }

  func getDisplayName() async -> String {
    await toxService.getDisplayName()
  }

  func setStatusMessage(_ message: String) {
    Task {
      do {
        try await toxService.setStatusMessage(message)
      } catch {
        print("Не удалось установить статус-сообщение: \(error)")
      }
    }
  }

  func friendExists(_ friendID: UInt32) async -> Bool {
    await toxService.friendExists(friendID)
  }

  func getFriendLastOnline(_ friendID: UInt32) async -> UInt64 {
    await toxService.getFriendLastOnline(friendID)
  }

  func getFriendPublicKey(_ friendID: UInt32) async -> Data {
    await toxService.getFriendPublicKey(friendID)
  }

  func getFileID(ofFriend friendID: UInt32, at index: UInt32) async -> UInt32? {
    await toxService.getFileID(ofFriend: friendID, at: index)
  }

  func controlFile(toFriend friendID: UInt32, fileID: UInt32, control: FileControl) {
    Task {
      do {
        try await toxService.controlFile(toFriend: friendID, fileID: fileID, control: control)
      } catch {
        print("Ошибка controlFile: \(error)")
      }
    }
  }

  func seekFile(toFriend friendID: UInt32, fileID: UInt32, position: UInt64) {
    Task {
      do {
        try await toxService.seekFile(toFriend: friendID, fileID: fileID, position: position)
      } catch {
        print("Ошибка seekFile: \(error)")
      }
    }
  }

  func joinConference(fromFriend friendID: UInt32, cookie: Data) {
    Task {
      do {
        let confID = try await toxService.joinConference(fromFriend: friendID, cookie: cookie)
        print("Успешно присоединились к конференции #\(confID)")
        await refreshConferencesList()
      } catch {
        print("Не удалось присоединиться к конференции: \(error)")
      }
    }
  }

  func setConferenceTitle(_ conferenceID: UInt32, title: String) {
    Task {
      do {
        try await toxService.setConferenceTitle(conferenceID, title: title)
        if let idx = conferences.firstIndex(where: { $0.id == conferenceID }) {
          conferences[idx].title = title
        }
      } catch {
        print("Не удалось установить заголовок конференции: \(error)")
      }
    }
  }

  func exportSavedata() async -> Data {
    await toxService.exportSavedata()
  }

  // MARK: - Статические методы (proxy для toxService)

  static func libraryVersion() -> (major: UInt32, minor: UInt32, patch: UInt32) {
    ToxService.libraryVersion
  }

  static func isCompatible(major: UInt32, minor: UInt32, patch: UInt32) -> Bool {
    ToxService.isCompatible(major: major, minor: minor, patch: patch)
  }

  // MARK: - Persistence
  private func persistState() {
    Task.detached(priority: .background) { [weak self] in
      guard let self else { return }
      let data = await self.toxService.exportSavedata()
      let base64 = data.base64EncodedString()
      await MainActor.run {
        self.toxSavedataBase64 = base64
        print("❤️ Сохранен")
      }
    }
  }
}

// MARK: - Пример дополнительных моделей (для хранения во @Published)

// MARK: - Утилита для hex -> Data
extension Data {
  init?(hexString: String) {
    let cleaned = hexString
      .replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: "-", with: "")

    guard cleaned.count % 2 == 0 else {
      return nil
    }

    var data = Data(capacity: cleaned.count / 2)
    var index = cleaned.startIndex
    while index < cleaned.endIndex {
      let byteString = cleaned[index..<cleaned.index(index, offsetBy: 2)]
      if let byte = UInt8(byteString, radix: 16) {
        data.append(byte)
      } else {
        return nil
      }
      index = cleaned.index(index, offsetBy: 2)
    }

    self = data
  }
}

extension ToxManager {
  func createJSONString(from model: MessengerNetworkRequestModel) -> String? {
    let encoder = JSONEncoder()

    do {
      let jsonData = try encoder.encode(model)
      guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        print("Ошибка преобразования данных JSON в строку.")
        return nil
      }
      return jsonString
    } catch {
      print("Ошибка кодирования модели в JSON: \(error)")
      return nil
    }
  }
}

#if DEBUG
@MainActor
extension ToxManager {
  /// Заглушка с демо-данными, чтобы превью работало офлайн
  static var preview: ToxManager {
    let manager = ToxManager.shared
    manager.friends = FriendModel.mockList()
    manager.messages = [
      1: ChatMessage.mockList(friendID: 1),
      2: ChatMessage.mockList(friendID: 2),
      3: ChatMessage.mockList(friendID: 3)
    ]
    manager.friendRequests = FriendRequest.mockList()
    manager.connectionState = .online
    return manager
  }
}
#endif
