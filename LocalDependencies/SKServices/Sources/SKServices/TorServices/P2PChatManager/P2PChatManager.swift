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
  private var fileData: Data?
  var fileInfo: (friendNumber: Int32, fileId: Int32, fileName: String, fileSize: UInt64)?
  
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
  
  func sendFile(
    toxPublicKey: String,
    model: MessengerNetworkRequestDTO,
    recordModel: MessengeRecordingModel?,
    files: [URL]
  ) {
    clearTemporaryDirectory()
    
    // MARK: - ШАГ 1 Инициализация отправки файла ❤️❤️❤️
    let encoder = JSONEncoder()
    
    let tempDirectory = FileManager.default.temporaryDirectory
    let modelURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("model")
    let recordURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("record")
    let archiveURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("zip")
    
    do {
      let jsonData = try encoder.encode(model)
      let recordData = try? encoder.encode(recordModel)
      // Сохранение model во временное хранилище
      try jsonData.write(to: modelURL)
      
      if let recordData {
        try recordData.write(to: recordURL)
      }
      
      
      // Преобразование имен файлов в нижний регистр
      var pathsToArchive = [URL]()
      for fileURL in files {
        let lowercasedFileName = fileURL.lastPathComponent.lowercased()
        let lowercasedFileURL = tempDirectory.appendingPathComponent(lowercasedFileName)
        try FileManager.default.copyItem(at: fileURL, to: lowercasedFileURL)
        pathsToArchive.append(lowercasedFileURL)
      }
      pathsToArchive.append(modelURL)
      
      if recordData != nil {
        pathsToArchive.append(recordURL)
      }
      
      // Архивирование model и files
      try zipArchiveService.zipFiles(atPaths: pathsToArchive, toDestination: archiveURL)
      
      // Чтение данных архива
      let fileData = try Data(contentsOf: archiveURL)
      self.fileData = fileData
      
      // Получение номера друга по публичному ключу
      guard let friendNumber = toxCore.friendNumber(publicKey: toxPublicKey) else {
        print("Не удалось получить номер друга по публичному ключу.")
        return
      }
      
      // Проверка существования друга
      guard toxCore.friendExists(friendNumber: friendNumber) else {
        print("Друг не найден для friendNumber: \(friendNumber)")
        return
      }
      
      let fileName = archiveURL.lastPathComponent
      let fileSize = UInt64(fileData.count)
      
      // Инициализация отправки файла
      toxCore.sendFile(to: friendNumber, fileName: fileName, fileSize: fileSize) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(fileId):
          print("✅ Файл инициализирован, fileId: \(fileId)")
          
        case let .failure(error):
          print("❌ Ошибка при инициализации отправки файла: \(error.localizedDescription)")
        }
      }
    } catch {
      print("❌ Ошибка при сохранении или архивировании файлов: \(error.localizedDescription)")
    }
  }
}

// MARK: - Private

@available(iOS 16.0, *)
extension P2PChatManager {
  func clearTemporaryDirectory() {
    let tempDirectory = FileManager.default.temporaryDirectory
    
    do {
      let tempDirectoryContents = try FileManager.default.contentsOfDirectory(
        at: tempDirectory,
        includingPropertiesForKeys: nil,
        options: []
      )
      for file in tempDirectoryContents {
        try FileManager.default.removeItem(at: file)
      }
      print("Temporary directory cleared successfully.")
    } catch {
      print("Error clearing temporary directory: \(error)")
    }
  }
  
  // Коллбек для отправки запрошенных чанков
  func sendChunk(
    to friendNumber: Int32,
    fileId: Int32,
    position: UInt64,
    length: size_t,
    completion: ((Result<Double, Error>) -> Void)?
  ) {
    guard let fileData else {
      print("Ошибка: данные файла не найдены")
      completion?(.failure(URLError(.unknown)))
      return
    }
    
    // Проверяем, запрашивается ли чанк с нулевой длиной
    if length == .zero {
      print("Запрос на чанк с нулевой длиной, завершение передачи")
      completion?(.failure(URLError(.unknown)))
      return
    }
    
    let end = min(position + UInt64(length), UInt64(fileData.count))
    let chunk = fileData.subdata(in: Int(position)..<Int(end))
    let progress = Double(position + UInt64(length)) / Double(fileData.count) * 100
    
    toxCore.sendFileChunk(to: friendNumber, fileId: fileId, position: position, data: chunk) { result in
      switch result {
      case .success:
        print("Чанк отправлен, позиция: \(position), длина: \(length) байт")
        // Проверка завершения передачи файла
        if position + UInt64(length) >= UInt64(fileData.count) {
          print("Передача файла завершена")
        }
        completion?(.success(progress))
      case let .failure(error):
        completion?(.failure(error))
        print("❌ Ошибка при отправке чанка: \(error.localizedDescription)")
      }
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
