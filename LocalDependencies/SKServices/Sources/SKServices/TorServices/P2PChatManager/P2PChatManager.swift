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
  
  //  private var torService: ITorService = TorService.shared
  private let cloudKitService: ICloudKitService = CloudKitService()
  private var secureDataManagerService: ISecureDataManagerService = SecureDataManagerService(.configurationSecrets)
  
  // MARK: - Init
  
  private init() {
    //    Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [self] _ in
    //      let server = TorServer()
    //      self.torServer = server
    //      print("✅ Сервер запустился")
    //    }
    //    torService.stateAction = { [weak self] result in
    //      DispatchQueue.main.async { [weak self] in
    //        self?.sessionStateAction?(result)
    //      }
    //    }
  }
  
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
  }
  
  //    torService.start { [weak self] result in
  //      DispatchQueue.main.async {
  //        completion?(result)
  //      }
  //    }
  
  public func stop(completion: ((Result<Void, TorServiceError>) -> Void)?) {}
}

// MARK: - TOR

@available(iOS 16.0, *)
public extension P2PChatManager {
  
}

// MARK: - TOX

@available(iOS 16.0, *)
public extension P2PChatManager {
  public func toxStateAsString(completion: ((_ stateAsString: String?) -> Void)?) {
    DispatchQueue.main.async { [weak self] in
      completion?(self?.toxCore.saveToxStateAsString())
    }
  }
  
  public func getToxAddress(completion: @escaping (Result<String, any Error>) -> Void) {
    DispatchQueue.main.async { [weak self] in
      completion(.success(self?.toxCore.getToxAddress() ?? ""))
    }
  }
  
  func addFriend(address: String, message: String, completion: ((_ contactID: Int32?) -> Void)?) {
    DispatchQueue.main.async { [weak self] in
      completion?(self?.toxCore.addFriend(address: address, message: message))
    }
  }
  
  func deleteFriend(toxPublicKey: String, completion: ((Bool) -> Void)?) {
    guard let friendNumber = toxCore.friendNumber(publicKey: toxPublicKey) else {
      DispatchQueue.main.async {
        completion?(false)
      }
      return
    }
    
    let result = toxCore.deleteFriend(friendNumber: friendNumber)
    DispatchQueue.main.async {
      completion?(result)
    }
  }
  
  func setUserIsTyping(
    _ isTyping: Bool,
    to toxPublicKey: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let friendNumber = toxCore.friendNumber(publicKey: toxPublicKey) else {
      DispatchQueue.main.async {
        completion(.failure(ToxError.friendNotFound))
      }
      return
    }
    toxCore.setUserIsTyping(isTyping, forFriendNumber: friendNumber) { result in
      DispatchQueue.main.async {
        switch result {
        case .success():
          completion(.success(()))
        case let .failure(error):
          completion(.failure(error))
        }
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
        
        DispatchQueue.main.async {
          completion(.success(publicKey))
        }
      case let .failure(error):
        DispatchQueue.main.async {
          completion(.failure(error))
        }
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
      DispatchQueue.main.async {
        completion(.failure(ToxError.friendNotFound))
      }
      return
    }
    
    toxCore.sendMessage(
      to: friendNumber,
      message: message,
      messageType: messageType.mapTo()) { result in
        switch result {
        case let .success(messageId):
          DispatchQueue.main.async {
            completion(.success(messageId))
          }
        case let .failure(error):
          DispatchQueue.main.async {
            completion(.failure(error))
          }
        }
      }
  }
  
  func getToxPublicKey(completion: @escaping (String?) -> Void) {
    DispatchQueue.main.async { [weak self] in
      completion(self?.toxCore.getPublicKey())
    }
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
      DispatchQueue.main.async {
        completion?(nil)
      }
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      let toxStatus = self?.toxCore.friendConnectionStatus(friendNumber: friendNumber)
      completion?(toxStatus?.mapTo())
    }
  }
  
  func friendNumber(publicToxKey: String, completion: ((_ contactID: Int32?) -> Void)?) {
    DispatchQueue.main.async { [weak self] in
      completion?(self?.toxCore.friendNumber(publicKey: publicToxKey))
    }
  }
  
  func setSelfStatus(isOnline: Bool) {
    toxCore.setSelfStatus(isOnline ? .online : .away)
  }
}

// MARK: - Private

@available(iOS 16.0, *)
private extension P2PChatManager {
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
        DispatchQueue.main.async {
          completion?(.success(()))
        }
      case let .failure(error):
        DispatchQueue.main.async {
          completion?(.failure(error))
        }
      }
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let nodesKeys = "nodes"
}
