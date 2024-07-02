//
//  P2PChatManager.swift
//  SwiftTor
//
//  Created by Vitalii Sosin on 02.06.2024.
//

import SwiftUI
import SKAbstractions
import ToxCore

@available(iOS 16.0, *)
public final class P2PChatManager: IP2PChatManager {
  
  // MARK: - Public properties
  
  public static let shared = P2PChatManager()
  public var sessionStateAction: ((_ state: TorSessionState) -> Void)?
  public let toxCore: ToxCore = ToxCore.shared
  
  // MARK: - Private properties
  
  //  private var torService = SwiftTor(start: true)
  private let cloudKitService: ICloudKitService = CloudKitService()
  private var secureDataManagerService: ISecureDataManagerService = SecureDataManagerService(.configurationSecrets)
  private var periodicFriendStatusChecktimer: DispatchSourceTimer?
  private let zipArchiveService = ZipArchiveService()
  
  // MARK: - Init
  
  private init() {}
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Public funcs
  
  public func start(
    saveDataString: String?,
    completion: ((Result<Void, Error>) -> Void)?
  ) {
    getConfigurationValue(forKey: Constants.nodesKeys) { [weak self] nodesJSON in
      guard let self else { return }
      
      configurationCallback()
      createNewTox(saveDataString: saveDataString, nodesJSON: nodesJSON, completion: completion)
    }
    
    //    startTorService { [weak self] result in
    //      guard let self else { return }
    //      switch result {
    //      case .success:
    //        getConfigurationValue(forKey: Constants.nodesKeys) { [weak self] nodesJSON in
    //          guard let self else { return }
    //
    //          configurationCallback()
    //          createNewTox(saveDataString: saveDataString, nodesJSON: nodesJSON, completion: completion)
    //        }
    //      case .failure(_):
    //        print("failure❌ ")
    //      }
    //    }
  }
  
  func startTorService(completion: ((Result<Void, Error>) -> Void)?) {
    //    torService.stateAction = { [weak self] result in
    //      switch result {
    //      case .none:
    //        print("none")
    //      case .started:
    //        print("started")
    //      case let .connectingProgress(result):
    //        print("connectingProgress \(result)")
    //      case .connected:
    //        print("connected")
    //      case .stopped:
    //        print("stopped")
    //      case .refreshing:
    //        print("refreshing")
    //      }
    //      DispatchQueue.main.async { [weak self] in
    //        self?.sessionStateAction?(result)
    //      }
    //    }
    
    //    torService.completion = { state in
    //      switch state {
    //      case .none:
    //        print("none")
    //      case .started:
    //        print("started")
    //      case .connected:
    //        print("connected")
    //        completion?(.success(()))
    //      case .stopped:
    //        print("stopped")
    //      case .refreshing:
    //        print("refreshing")
    //      }
    //    }
  }
  
  public func stop(completion: ((Result<Void, TorServiceError>) -> Void)?) {}
}

// MARK: - TOR

@available(iOS 16.0, *)
public extension P2PChatManager {
  
}

// MARK: - TOX

@available(iOS 16.0, *)
public extension P2PChatManager {
  /// Запускает таймер для периодического вызова getFriendsStatus каждые 2 секунды.
  func startPeriodicFriendStatusCheck(completion: (([String: Bool]) -> Void)?) {
    let queue = DispatchQueue.global(qos: .background)
    queue.async { [weak self] in
      guard let self = self else { return }
      self.periodicFriendStatusChecktimer?.cancel()
      self.periodicFriendStatusChecktimer = DispatchSource.makeTimerSource(queue: queue)
      self.periodicFriendStatusChecktimer?.schedule(deadline: .now(), repeating: 5.0)
      self.periodicFriendStatusChecktimer?.setEventHandler { [weak self] in
        self?.getFriendsStatus(completion: completion)
      }
      self.periodicFriendStatusChecktimer?.resume()
    }
  }
  
  public func toxStateAsString(completion: ((_ stateAsString: String?) -> Void)?) {
    completion?(toxCore.saveToxStateAsString())
  }
  
  public func getToxAddress(completion: @escaping (Result<String, any Error>) -> Void) {
    completion(.success(toxCore.getToxAddress() ?? ""))
  }
  
  func addFriend(address: String, message: String, completion: ((_ contactID: Int32?) -> Void)?) {
    completion?(toxCore.addFriend(address: address, message: message))
  }
  
  func deleteFriend(toxPublicKey: String, completion: ((Bool) -> Void)?) {
    guard let friendNumber = toxCore.friendNumber(publicKey: toxPublicKey) else {
      completion?(false)
      return
    }
    
    let result = toxCore.deleteFriend(friendNumber: friendNumber)
    completion?(result)
  }
  
  func setUserIsTyping(
    _ isTyping: Bool,
    to toxPublicKey: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let friendNumber = toxCore.friendNumber(publicKey: toxPublicKey) else {
      completion(.failure(ToxError.friendNotFound))
      return
    }
    toxCore.setUserIsTyping(isTyping, forFriendNumber: friendNumber) { result in
      switch result {
      case .success():
        completion(.success(()))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
  
  func confirmFriendRequest(
    with publicToxKey: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    toxCore.confirmFriendRequest(with: publicToxKey) { [weak self] result in
      guard let self else { return }
      switch result {
      case let .success(friendID):
        guard let publicKey = toxCore.publicKeyFromFriendNumber(friendNumber: friendID) else {
          DispatchQueue.main.async {
            completion(.failure(ToxError.friendNotFound))
          }
          return
        }
        
        completion(.success(publicKey))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
  
  func sendMessage(
    to toxPublicKey: String,
    message: String,
    messageType: ToxSendMessageType,
    completion: @escaping (Result<Int32, Error>) -> Void
  ) {
    guard let friendNumber = toxCore.friendNumber(publicKey: toxPublicKey) else {
      completion(.failure(ToxError.friendNotFound))
      return
    }
    
    toxCore.sendMessage(
      to: friendNumber,
      message: message,
      messageType: messageType.mapTo()) { result in
        switch result {
        case let .success(messageId):
          completion(.success(messageId))
        case let .failure(error):
          completion(.failure(error))
        }
      }
  }
  
  func getToxPublicKey(completion: @escaping (String?) -> Void) {
    completion(toxCore.getPublicKey())
  }
  
  func getToxPublicKey(from address: String) -> String? {
    // Адрес должен быть длиной 76 символов
    guard address.count == 76 else {
      print("❌ Неправильный формат адреса")
      return nil
    }
    
    // Публичный ключ - это первые 64 символа (32 байта) адреса
    let publicKey = String(address.prefix(64))
    return publicKey
  }
  
  func friendConnectionStatus(toxPublicKey: String, completion: ((ConnectionToxStatus?) -> Void)?) {
    guard let friendNumber = toxCore.friendNumber(publicKey: toxPublicKey) else {
      completion?(nil)
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      let toxStatus = self?.toxCore.friendConnectionStatus(friendNumber: friendNumber)
      completion?(toxStatus?.mapTo())
    }
  }
  
  func friendNumber(publicToxKey: String, completion: ((_ contactID: Int32?) -> Void)?) {
    completion?(toxCore.friendNumber(publicKey: publicToxKey))
  }
  
  func setSelfStatus(isOnline: Bool) {
    toxCore.setSelfStatus(isOnline ? .online : .away)
  }
  
  func sendFile(toxPublicKey: String, model: MessengerNetworkRequestDTO, files: [URL]) {
    let encoder = JSONEncoder()
    
    let tempDirectory = FileManager.default.temporaryDirectory
    let modelURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("model")
    let archiveURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("zip")
    
    do {
      let jsonData = try encoder.encode(model)
      // Сохранение model во временное хранилище
      try jsonData.write(to: modelURL)
      
      // Архивирование model и files
      var pathsToArchive = files
      pathsToArchive.append(modelURL)
      try zipArchiveService.zipFiles(atPaths: pathsToArchive, toDestination: archiveURL)
      
      // Чтение данных архива
      let fileData = try Data(contentsOf: archiveURL)
      
      // Получение номера друга по публичному ключу
      guard let friendNumber = toxCore.friendNumber(publicKey: toxPublicKey) else {
        print("Не удалось получить номер друга по публичному ключу.")
        return
      }
      
      let fileName = archiveURL.lastPathComponent
      let fileSize = UInt64(fileData.count)
      
      // Инициализация отправки файла
      toxCore.sendFile(to: friendNumber, fileName: fileName, fileSize: fileSize) { result in
        switch result {
        case let .success(fileId):
          print("✅ Файл инициализирован, fileId: \(fileId)")
          // Отправка чанков данных файла
          self.sendChunks(to: friendNumber, fileId: fileId, fileData: fileData)
        case let .failure(error):
          print("❌ Ошибка при инициализации отправки файла: \(error)")
        }
      }
    } catch {
      print("❌ Ошибка при сохранении или архивировании файлов: \(error)")
    }
  }
}

// MARK: - Private

@available(iOS 16.0, *)
private extension P2PChatManager {
  func sendChunks(to friendNumber: Int32, fileId: Int32, fileData: Data) {
    // Размер чанка 16 КБ
    let chunkSize = 1024 * 16
    var position: UInt64 = 0
    let totalSize = UInt64(fileData.count)
    
    while position < totalSize {
      let end = min(position + UInt64(chunkSize), totalSize)
      let chunk = fileData[Int(position)..<Int(end)]
      
      ToxCore.shared.sendFileChunk(to: friendNumber, fileId: fileId, position: position, data: chunk) { result in
        switch result {
        case .success:
          print("Чанк отправлен, позиция: \(position)")
          
          // Обновление прогресса
          let progress = Double(position + UInt64(chunk.count)) / Double(totalSize) * 100
          print(String(format: "🟡 Прогресс отправки: %.2f%%", progress))
          
          // Если отправка завершена
          if position + UInt64(chunk.count) >= totalSize {
            print("🟢 Отправка файла завершена.")
          }
          
        case .failure(let error):
          print("❌ Ошибка при отправке чанка: \(error)")
        }
      }
      position += UInt64(chunk.count)
    }
  }
  
  func getFriendsStatus(completion: (([String: Bool]) -> Void)?) {
    var friendDictionaryStatus: [String: Bool] = [:]
    
    toxCore.getFriendList { [weak self] result in
      guard let self else { return }
      switch result {
      case let .success(friendList):
        for friendID in friendList {
          let result = toxCore.friendConnectionStatus(friendNumber: Int32(friendID)) ?? .none
          let isOnline: Bool
          switch result {
          case .none:
            isOnline = false
          case .tcp, .udp:
            isOnline = true
          }
          
          if let publicKey = toxCore.publicKeyFromFriendNumber(friendNumber: Int32(friendID)) {
            friendDictionaryStatus.updateValue(isOnline, forKey: publicKey)
          }
        }
        completion?(friendDictionaryStatus)
      case .failure: break
      }
    }
  }
  
  func getConfigurationValue(forKey key: String, completion: @escaping (String) -> Void) {
    if let value = secureDataManagerService.getString(for: key) {
      completion(value)
    }
    
    cloudKitService.getConfigurationValue(from: key) { [weak self] (value: String?) in
      if let value {
        completion(value)
        self?.secureDataManagerService.saveString(value, key: key)
      }
    }
  }
  
  func createNewTox(
    saveDataString: String?,
    nodesJSON: String,
    completion: ((Result<Void, Error>) -> Void)?
  ) {
    var options = ToxOptions()
    options.ipv6Enabled = true
    options.udpEnabled = false
    options.startPort = 0
    options.endPort = 0
    options.tcpPort = 0
    options.useTorProxy = false
    
    toxCore.createNewTox(
      with: options,
      savedDataString: saveDataString,
      toxNodesJsonString: nodesJSON
    ) { [self] resulr in
      switch resulr {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let nodesKeys = "nodes"
}
