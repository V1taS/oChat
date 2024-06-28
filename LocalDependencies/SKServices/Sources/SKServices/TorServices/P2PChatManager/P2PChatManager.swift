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
}

// MARK: - Private

@available(iOS 16.0, *)
private extension P2PChatManager {
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
