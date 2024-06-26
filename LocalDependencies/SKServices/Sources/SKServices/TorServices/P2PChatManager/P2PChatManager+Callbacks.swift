//
//  P2PChatManager+Callbacks.swift
//  SKServices
//
//  Created by Vitalii Sosin on 22.06.2024.
//

import SwiftUI
import SKAbstractions
import ToxCore

// MARK: - ConfigurationCallback

@available(iOS 16.0, *)
extension P2PChatManager {
  func configurationCallback() {
    setConnectionStatusCallback()
    setFriendRequestCallback()
    setMessageCallback()
    setSessionTORCallback()
    setFriendStatusCallback()
    setLogCallback()
    setFriendStatusOnlineCallback()
    setFriendTypingCallback()
    setFriendReadReceiptCallback()
  }
}

// MARK: - Callbacks SETS

@available(iOS 16.0, *)
private extension P2PChatManager {
  func setFriendReadReceiptCallback() {
    toxCore.setFriendReadReceiptCallback { [weak self] friendId, messageId in
      self?.updateFriendReadReceiptCallback(friendId, messageId)
    }
  }
  
  func setFriendTypingCallback() {
    toxCore.setFriendTypingCallback { [weak self] friendId, isTyping in
      self?.updateFriendTyping(friendId, isTyping)
    }
  }
  
  func setFriendStatusOnlineCallback() {
    toxCore.setFriendStatusOnlineCallback { [weak self] friendId, status in
      self?.updateFriendStatusOnline(friendId: friendId, status: status)
    }
  }
  
  func setFriendStatusCallback() {
    toxCore.setFriendStatusCallback { [weak self] friendId, connectionStatus in
      let status: UserStatus
      switch connectionStatus {
      case .none:
        status = .away
      case .tcp:
        status = .online
      case .udp:
        status = .online
      }
      self?.updateFriendStatusOnline(friendId: friendId, status: status)
    }
  }
  
  func setLogCallback() {
    toxCore.setLogCallback { file, level, funcName, line, message, arg, userData in
      let logMessage = "\(file):\(line) - \(funcName): \(message) [\(arg)]"
      
      switch level {
      case .trace:
        print("🛤️ TRACE: \(logMessage)")
      case .debug:
        print("🔍 DEBUG: \(logMessage)")
      case .info:
        print("ℹ️ INFO: \(logMessage)")
      case .warning:
        print("⚠️ WARNING: \(logMessage)")
      case .error:
        print("❌ ERROR: \(logMessage)")
      }
    }
  }
  
  func setFriendRequestCallback() {
    toxCore.setFriendRequestCallback { [weak self] toxPublicKey, jsonString in
      guard let self else { return }
      updateDidReceiveRequestChat(jsonString: jsonString, toxPublicKey: toxPublicKey)
    }
  }
  
  func setConnectionStatusCallback() {
    toxCore.setConnectionStatusCallback { [weak self] connectionStatus in
      guard let self else { return }
      switch connectionStatus {
      case .none:
        updateMyOnlineStatus(status: .offline)
      case .tcp:
        updateMyOnlineStatus(status: .online)
      case .udp:
        updateMyOnlineStatus(status: .online)
      }
    }
  }
  
  func setSessionTORCallback() {
    //    torService.stateAction = { [weak self] result in
    //      guard let self else { return }
    //      switch result {
    //      case .none: break
    //      case .started: break
    //      case .connectingProgress: break
    //      case .connected: break
    //      case .stopped:
    //        updateMyOnlineStatus(status: .offline)
    //        torService.stop()
    //        torService.start(completion: { _ in })
    //      case .refreshing:
    //        updateMyOnlineStatus(status: .inProgress)
    //      }
    //      updateSessionState(state: result)
    //    }
  }
  
  func setMessageCallback() {
    toxCore.setMessageCallback { [weak self] friendId, jsonString in
      guard let self else { return }
      updateDidReceiveMessage(jsonString: jsonString, friendId: friendId)
    }
  }
}

// MARK: - Callbacks UPDATES

@available(iOS 16.0, *)
private extension P2PChatManager {
  func updateFriendReadReceiptCallback(_ friendId: UInt32, _ messageId: UInt32) {
    guard let publicKey = toxCore.publicKeyFromFriendNumber(friendNumber: Int32(friendId)) else {
      return
    }
    
    DispatchQueue.main.async {
      // Отправка уведомления о том что сообщение доставлено
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didUpdateFriendReadReceipt.rawValue),
        object: nil,
        userInfo: [
          "publicKey": publicKey,
          "messageId": messageId
        ]
      )
    }
  }
  
  func updateFriendTyping(_ friendId: Int32, _ isTyping: Bool) {
    guard let publicKey = toxCore.publicKeyFromFriendNumber(friendNumber: friendId) else {
      return
    }
    
    DispatchQueue.main.async {
      // Отправка уведомления о том печатает ли пользователь сейчас
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.isTyping.rawValue),
        object: nil,
        userInfo: [
          "publicKey": publicKey,
          "isTyping": isTyping
        ]
      )
    }
  }
  
  func updateFriendStatusOnline(friendId: Int32, status: UserStatus) {
    guard let publicKey = toxCore.publicKeyFromFriendNumber(friendNumber: friendId) else {
      return
    }
    
    DispatchQueue.main.async {
      // Отправка уведомления об изменении статуса ОНЛАЙН/ОФФ ЛАЙН друзей
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didUpdateFriendOnlineStatus.rawValue),
        object: nil,
        userInfo: [
          "publicKey": publicKey,
          "status": status.mapTo()
        ]
      )
    }
  }
  
  func updateMyOnlineStatus(status: MessengerModel.Status) {
    DispatchQueue.main.async {
      // Отправка уведомления об изменении статуса ОНЛАЙН/ОФФ ЛАЙН
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didUpdateMyOnlineStatus.rawValue),
        object: nil,
        userInfo: ["onlineStatus": status]
      )
    }
  }
  
  func updateDidReceiveMessage(jsonString: String?, friendId: Int32) {
    guard let jsonString,
          let jsonData = jsonString.data(using: .utf8),
          let dto = try? JSONDecoder().decode(MessengerNetworkRequestDTO.self, from: jsonData) else {
      return
    }
    
    DispatchQueue.main.async {
      // Отправка уведомления о получении нового сообщения
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didReceiveMessage.rawValue),
        object: nil,
        userInfo: [
          "data": dto.mapToModel(),
          "toxFriendId": friendId
        ]
      )
    }
  }
  
  func updateDidReceiveRequestChat(jsonString: String?, toxPublicKey: String) {
    guard let jsonString,
          let jsonData = jsonString.data(using: .utf8),
          let dto = try? JSONDecoder().decode(MessengerNetworkRequestDTO.self, from: jsonData) else {
      return
    }
    
    DispatchQueue.main.async {
      // Отправка уведомления о начале нового чата
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.didInitiateChat.rawValue),
        object: nil,
        userInfo: [
          "requestChat": dto.mapToModel(),
          "toxPublicKey": toxPublicKey
        ]
      )
    }
  }
  
  func updateSessionState(state: TorSessionState) {
    DispatchQueue.main.async {
      NotificationCenter.default.post(
        name: Notification.Name(NotificationConstants.sessionState.rawValue),
        object: nil,
        userInfo: ["sessionState": state]
      )
    }
  }
}
