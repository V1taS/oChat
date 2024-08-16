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
  public var messageBackgroundCallback: ((_ friendId: Int32, _ message: String) -> Void)?
  public let toxCore: ToxCore = ToxCore.shared
  
  // MARK: - Private properties
  
  private let cloudKitService: ICloudKitService = CloudKitService()
  private var secureDataManagerService: ISecureDataManagerService = SecureDataManagerService(.configurationSecrets)
  private var periodicFriendStatusChecktimer: DispatchSourceTimer?
  private let zipArchiveService = ZipArchiveService()
  private var fileData: Data?
  private let cryptoService = CryptoService()
  
  var fileInfo: (friendNumber: Int32, fileId: Int32, fileName: String, fileSize: UInt64)?
  var cacheMessengerModel: MessengerNetworkRequestDTO?
  let dataManagerService = DataManagerService()
  
  // MARK: - Init
  
  private init() {}
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Public funcs
  
  public func start(
    saveDataString: String?
  ) async throws {
    let nodesJSON: String = try await getConfigurationValue(forKey: Constants.nodesKeys)
    
    try await createNewTox(saveDataString: saveDataString, nodesJSON: nodesJSON)
    await configurationCallback()
  }
}

// MARK: - TOR

@available(iOS 16.0, *)
public extension P2PChatManager {
  
}

// MARK: - TOX

@available(iOS 16.0, *)
extension P2PChatManager {
  /// Запускает таймер для периодического вызова getFriendsStatus каждые 2 секунды.
  public func startPeriodicFriendStatusCheck(completion: @escaping ([String : Bool]) -> Void) async {
    Task { [weak self] in
      guard let self = self else { return }
      self.periodicFriendStatusChecktimer?.cancel()
      self.periodicFriendStatusChecktimer = DispatchSource.makeTimerSource(queue: .global())
      self.periodicFriendStatusChecktimer?.schedule(deadline: .now(), repeating: 5.0)
      self.periodicFriendStatusChecktimer?.setEventHandler { [weak self] in
        Task { [weak self] in
          guard let self else { return }
          let friendsStatus = await self.getFriendsStatus()
          completion(friendsStatus)
        }
      }
      self.periodicFriendStatusChecktimer?.resume()
    }
  }
  
  public func toxStateAsString() async -> String? {
    await toxCore.saveToxStateAsString()
  }
  
  
  public func getToxAddress() async -> String? {
    await toxCore.getToxAddress()
  }
  
  public func addFriend(address: String, message: String) async -> Int32? {
    await toxCore.addFriend(address: address, message: message)
  }
  
  public func deleteFriend(toxPublicKey: String) async -> Bool {
    guard let friendNumber = await toxCore.friendNumber(publicKey: toxPublicKey) else {
      return false
    }
    
    let result = await toxCore.deleteFriend(friendNumber: friendNumber)
    return result
  }
  
  public func setUserIsTyping(_ isTyping: Bool, to toxPublicKey: String) async -> Result<Void, Error> {
    guard let friendNumber = await toxCore.friendNumber(publicKey: toxPublicKey) else {
      return .failure(ToxError.friendNotFound)
    }
    
    do {
      try await toxCore.setUserIsTyping(isTyping, forFriendNumber: friendNumber)
      return .success(())
    } catch {
      return .failure(error)
    }
  }
  
  public func confirmFriendRequest(with publicToxKey: String) async -> String? {
    let result = try await toxCore.confirmFriendRequest(with: publicToxKey)
    guard let friendID = try? result.get(),
          let publicKey = await toxCore.publicKeyFromFriendNumber(friendNumber: friendID) else {
      return nil
    }
    return publicKey
  }
  
  public func sendMessage(
    to toxPublicKey: String,
    message: String,
    messageType: ToxSendMessageType
  ) async throws -> Int32? {
    guard let friendNumber = await toxCore.friendNumber(publicKey: toxPublicKey) else {
      throw ToxError.friendNotFound
    }
    
    let result = try await toxCore.sendMessage(
      to: friendNumber,
      message: message,
      messageType: messageType.mapTo()
    )
    
    return try? result.get()
  }
  
  
  public func getToxPublicKey() async -> String? {
    await toxCore.getPublicKey()
  }
  
  public func getToxPublicKey(from address: String) -> String? {
    // Адрес должен быть длиной 76 символов
    guard address.count == 76 else {
      print("❌ Неправильный формат адреса")
      return nil
    }
    
    // Публичный ключ - это первые 64 символа (32 байта) адреса
    let publicKey = String(address.prefix(64))
    return publicKey
  }
  
  public func friendConnectionStatus(toxPublicKey: String) async -> ConnectionToxStatus? {
    guard let friendNumber = await toxCore.friendNumber(publicKey: toxPublicKey) else {
      return nil
    }
    
    let toxStatus = await toxCore.friendConnectionStatus(friendNumber: friendNumber)
    return toxStatus?.mapTo()
  }
  
  public func friendNumber(publicToxKey: String) async -> Int32? {
    await toxCore.friendNumber(publicKey: publicToxKey)
  }
  
  public func setSelfStatus(isOnline: Bool) async {
    await toxCore.setSelfStatus(isOnline ? .online : .away)
  }
  
  public func sendFile(
    toxPublicKey: String,
    recipientPublicKey: String,
    model: MessengerNetworkRequestDTO,
    recordModel: MessengeRecordingModel?,
    files: [URL]
  ) {
    dataManagerService.clearTemporaryDirectory()
    var recordDTO: MessengeRecordingDTO?
    
    if let recordModel,
       let url = recordModel.url,
       let data = dataManagerService.readObjectWith(fileURL: url) {
      recordDTO = .init(
        duration: recordModel.duration,
        waveformSamples: recordModel.waveformSamples,
        data: data
      )
    }

    cacheMessengerModel = model
    let encoder = JSONEncoder()
    
    let password = generatePassword(length: 30)
    let passwordEncrypt = cryptoService.encrypt(password, publicKey: recipientPublicKey)
    guard let passwordEncrypt,
          let passwordEncodedString = passwordEncrypt.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
      return
    }
    
    let tempDirectory = FileManager.default.temporaryDirectory
    let modelURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("model")
    let recordURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("record")
    let archiveURL = tempDirectory.appendingPathComponent(passwordEncodedString).appendingPathExtension("zip")
    
    do {
      let jsonData = try encoder.encode(model)
      let recordData = try? encoder.encode(recordDTO)
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
      try zipArchiveService.zipFiles(
        atPaths: pathsToArchive,
        toDestination: archiveURL,
        password: password
      )
      
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
  func generatePassword(length: Int) -> String {
    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:',.<>?/~`"
    let charactersArray = Array(characters)
    var password = ""
    
    for _ in 0..<length {
      if let randomCharacter = charactersArray.randomElement() {
        password.append(randomCharacter)
      }
    }
    
    return password
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
      completion?(.success(100))
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
        if progress < 100 {
          completion?(.failure(error))
          print("❌ Ошибка при отправке чанка: \(error.localizedDescription)")
        }
      }
    }
  }
  
  func getFriendsStatus() async -> [String: Bool] {
    var friendDictionaryStatus: [String: Bool] = [:]
    
    switch await toxCore.getFriendList() {
    case let .success(friendList):
      for friendID in friendList {
        let result = await toxCore.friendConnectionStatus(friendNumber: Int32(friendID)) ?? .none
        let isOnline: Bool
        switch result {
        case .none:
          isOnline = false
        case .tcp, .udp:
          isOnline = true
        }
        
        if let publicKey = await toxCore.publicKeyFromFriendNumber(friendNumber: Int32(friendID)) {
          friendDictionaryStatus.updateValue(isOnline, forKey: publicKey)
        }
      }
      return friendDictionaryStatus
    case .failure:
      return [:]
    }
  }
  
  public func getConfigurationValue(forKey key: String) async throws -> String {
    // Попытка получить значение из secureDataManagerService
    if let value = secureDataManagerService.getString(for: key) {
      return value
    }
    
    // Получение значения из cloudKitService
    do {
      let cloudKitValue: String? = try await cloudKitService.getConfigurationValue(from: key)
      if let cloudKitValue = cloudKitValue {
        // Сохранение полученного значения в secureDataManagerService
        secureDataManagerService.saveString(cloudKitValue, key: key)
        return cloudKitValue
      } else {
        throw URLError(.unknown)
      }
    } catch {
      throw error
    }
  }
  
  func createNewTox(
    saveDataString: String?,
    nodesJSON: String
  ) async throws {
    var options = ToxOptions()
    options.ipv6Enabled = true
    options.udpEnabled = false
    options.startPort = 0
    options.endPort = 0
    options.tcpPort = 0
    options.useTorProxy = false
    
    try await toxCore.createNewTox(
      with: options,
      savedDataString: saveDataString,
      toxNodesJsonString: nodesJSON
    )
  }
}

// MARK: - Constants

private enum Constants {
  static let nodesKeys = "nodes"
}
