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

  /// Пул тасков для обработки бесконечных AsyncStream.
  private var tasks = Set<Task<Void, Never>>()

  // MARK: - Публикуемые свойства (отражение состояния в UI)

  /// Список друзей (их ID, имя, статус и т.д.).
  @Published var friends: [FriendModel] = []

  /// Все входящие/исходящие сообщения (в реальном приложении можно хранить раздельно по чатам).
  @Published var messages: [ChatMessage] = []

  /// Активные/известные конференции.
  @Published var conferences: [ConferenceModel] = []

  /// Список входящих/исходящих файлов (для трекинга прогресса).
  @Published var fileTransfers: [FileTransferModel] = []

  /// Состояние звонков (например, активные звонки по friendID).
  @Published var activeCalls: [UInt32: CallState] = [:]

  /// Статус подключения к DHT (для UI)
  @Published var dhtConnectionState: ConnectionState = .none

  /// Сводка чатов
  @Published private(set) var chatSummaries: [ChatSummary] = []

  @AppStorage("toxSavedata")
  private var toxSavedataBase64: String = ""

  // MARK: - Инициализация

  private init() {
    startToxService()

//    // Сохраняем при сворачивании приложения
//    NotificationCenter.default.addObserver(
//      forName: UIApplication.willResignActiveNotification,
//      object: nil,
//      queue: .main
//    ) { [weak self] _ in self?.persistState() }
  }

  // MARK: - Жизненный цикл Tox-ядра

  func startToxService() {
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
    // 3. Отключаемся от сети и освобождаем ресурсы toxcore
    await toxService.shutdown()
    print("🚨 Остановка Tox-ядра")
  }

  /// Полный рестарт ядра с сохранением профиля.
  /// Вызывайте при возврате в foreground или при выявленной потере связи.
  func restart() async throws {
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
        handleIncomingMessage(incoming)
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
        handleFriendEvent(friendEvent)
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

  private func handleIncomingMessage(_ incoming: IncomingMessage) {
    Task {
      // Добавляем в общий список сообщений
      let newMessage = ChatMessage(
        friendID: incoming.friendID,
        kind: incoming.kind,
        text: incoming.text,
        isOutgoing: false,
        timestamp: Date(),
        isDelivered: true,
        isRead: false

      )
      messages.append(newMessage)

      await rebuildChatSummaries()
      persistState()
    }
  }

  private func handleFileEvent(_ event: FileEvent) {
    switch event {
    case let .incomingRequest(friendID, fileID, kind, size, fileName):
      // Создадим модель "входящего файла" и добавим в список
      let transfer = FileTransferModel(
        friendID: friendID,
        fileID: fileID,
        kind: kind,
        fileName: fileName,
        fileSize: size,
        progress: 0.0,
        status: .incoming
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

  private func handleFriendEvent(_ event: FriendEvent) {
    switch event {
    case let .request(publicKey, message):
      // Кто-то стучится к нам. Можно решить: автоматически добавить или спросить у пользователя
      Task {
        do {
          let friendID = try await toxService.acceptFriendRequest(publicKey: publicKey)
          print("✅ Приняли запрос; friendID = \(friendID)")
          await refreshFriendsList()
          // message содержит приветствие отправителя — можете сохранить/показать в UI
        } catch {
          print("❌ Не удалось принять запрос: \(error)")
        }
      }

    case let .nameChanged(friendID, name):
      if let idx = friends.firstIndex(where: { $0.id == friendID }) {
        friends[idx].name = name
      }

    case let .statusMessageChanged(friendID, message):
      if let idx = friends.firstIndex(where: { $0.id == friendID }) {
        friends[idx].statusMessage = message
      }

    case let .userStatusChanged(friendID, status):
      if let idx = friends.firstIndex(where: { $0.id == friendID }) {
        friends[idx].userStatus = status
      }

    case let .connectionStatusChanged(friendID, state):
      if let idx = friends.firstIndex(where: { $0.id == friendID }) {
        friends[idx].connectionState = state
      }

    case let .typing(friendID, isTyping):
      // Можно показывать индикатор "Печатает..." в UI
      print("Друг \(friendID) typing = \(isTyping)")

    case let .readReceipt(friendID, messageID):
      // Удобно отмечать, что сообщение прочитано
      print("Друг \(friendID) прочитал сообщение \(messageID)")
//      if let idx = messages.firstIndex(where: { $0.id == messageID }) {
//        messages[idx].isDelivered = true
//        messages[idx].isRead = true
//      }

    case let .lossyPacket(friendID, data):
      // Свои низкоуровневые пакеты (например, для игр)
      print("Получен lossy-пакет размером \(data.count) от друга \(friendID)")

    case let .losslessPacket(friendID, data):
      print("Получен lossless-пакет размером \(data.count) от друга \(friendID)")
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

  private func handleDHTConnectionState(_ state: ConnectionState) {
    // Сохраняем в @Published-свойство, чтобы UI мог реагировать
    dhtConnectionState = state

    print("Изменился статус DHT-подключения: \(state)")
    Task {
      print("OwnAddress: \(await getOwnAddress())")
    }
  }

  // MARK: - Методы для обновления локальных списков

  func rebuildChatSummaries() async {
    var map: [UInt32: ChatSummary] = [:]

    // 1. друзья → базовая строка
    for f in friends {
      map[f.id] = ChatSummary(
        id: f.id,
        contactEmoji: nil,                    // заполняйте своей логикой
        address: await toxService.getFriendAddress(f.id),
        isOnline: f.connectionState == .tcp,
        isTyping: false,                      // когда появится событие typing → обновить
        unreadCount: 0,
        lastMessage: nil
      )
    }

    // 2. последние сообщения → обновляем каждую строку
    for msg in messages.sorted(by: { $0.timestamp > $1.timestamp }) {
      guard var s = map[msg.friendID] else { continue }
      if s.lastMessage == nil {
        let kind = LastMessageSummary.Kind.text(msg.text)
        s.lastMessage = LastMessageSummary(
          kind: kind,
          isOutgoing: msg.isOutgoing,
          isDelivered: true,                 // TODO: подхватить реальный статус
          isRead: !msg.isOutgoing            // читаем входящее сразу, исходящее → ждём квитанцию
        )
        map[msg.friendID] = s
      }
    }

    chatSummaries = map.values.sorted { ($0.lastMessage?.preview ?? "") > ($1.lastMessage?.preview ?? "") }
  }

  func refreshFriendsList() async {
    let friendIDs = await toxService.friendList()
    var updatedFriends: [FriendModel] = []

    for friendID in friendIDs {
      let name = await toxService.getFriendName(friendID)
      let statusMessage = await toxService.getFriendStatusMessage(friendID)
      let connectionState = await toxService.getFriendConnectionStatus(forID: friendID)
      let userStatus = await toxService.getFriendUserStatus(friendID)

      let model = FriendModel(
        id: friendID,
        name: name,
        statusMessage: statusMessage,
        userStatus: userStatus,
        connectionState: connectionState
      )
      updatedFriends.append(model)
    }

    self.friends = updatedFriends
    await rebuildChatSummaries()
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

  /// Отправить сообщение конкретному другу.
  func sendMessage(to friendID: UInt32, text: String) {
    Task {
      do {
        try await toxService.sendMessage(
          toFriend: friendID,
          text: text,
          type: .normal
        )
        // Сохраним и в локальный массив (как исходящее)
        let outgoing = ChatMessage(
          friendID: friendID,
          kind: .normal,
          text: text,
          isOutgoing: true,
          timestamp: Date(),
          isDelivered: false,
          isRead: false
        )
        messages.append(outgoing)
        await rebuildChatSummaries()
        persistState()
      } catch {
        print("Ошибка отправки сообщения другу \(friendID): \(error)")
      }
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
  func sendFile(to friendID: UInt32, fileURL: URL) {
    Task {
      do {
        let fileData = try Data(contentsOf: fileURL)
        let fileSize = UInt64(fileData.count)
        let fileName = fileURL.lastPathComponent

        let fileID = try await toxService.sendFile(
          toFriend: friendID,
          kind: .data,
          size: fileSize,
          fileName: fileName
        )

        // Добавляем в локальный список, чтобы трекать
        let transfer = FileTransferModel(
          friendID: friendID,
          fileID: fileID,
          kind: .data,
          fileName: fileName,
          fileSize: fileSize,
          progress: 0,
          status: .inProgress
        )
        fileTransfers.append(transfer)

        // Ждём, когда друг запросит chunk-и (или используем другую логику)
      } catch {
        print("Ошибка при отправке файла \(fileURL): \(error)")
      }
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

struct LastMessageSummary: Hashable {
  enum Kind: Hashable { case text(String), file, audioCall, videoCall }
  let kind: Kind
  let isOutgoing: Bool
  let isDelivered: Bool
  let isRead: Bool

  var preview: String {
    switch kind {
    case .text(let t):  t
    case .file:         "📁 Файл"
    case .audioCall:    "📞 Аудиозвонок"
    case .videoCall:    "🎥 Видеозвонок"
    }
  }
}

struct ChatSummary: Identifiable, Hashable {
  let id: UInt32                // = friendID
  let contactEmoji: String?     // 1-символьный emoji или nil
  let address: String           // 76-символьный адрес друга
  let isOnline: Bool
  let isTyping: Bool            // пока нет sdk-события, заглушка = false
  var unreadCount: Int
  var lastMessage: LastMessageSummary?
  var shortAddress: String { "\(address.prefix(5))…\(address.suffix(5))" }
}

/// Модель друга, чтобы удобно хранить в списке (для SwiftUI)
struct FriendModel: Identifiable {
  let id: UInt32
  var name: String
  var statusMessage: String
  var userStatus: UserStatus
  var connectionState: ConnectionState
}

/// Модель чата/сообщения
struct ChatMessage: Identifiable {
  let id = UUID() // локальный идентификатор для SwiftUI
  let friendID: UInt32
  let kind: MessageKind
  let text: String
  let isOutgoing: Bool
  let timestamp: Date
  var isDelivered: Bool
  var isRead: Bool
}

/// Модель конференции
struct ConferenceModel: Identifiable {
  let id: UInt32
  var title: String
  let type: ConferenceType
}

/// Модель файла в процессе отправки/приёма
struct FileTransferModel: Identifiable {
  let id = UUID()
  let friendID: UInt32
  let fileID: UInt32
  let kind: FileKind
  let fileName: String
  let fileSize: UInt64
  var progress: Double
  var status: TransferStatus
}

enum TransferStatus {
  case incoming, inProgress, paused, cancelled, completed
}

/// Статус звонка
struct CallState {
  var audioEnabled: Bool
  var videoEnabled: Bool
}

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
