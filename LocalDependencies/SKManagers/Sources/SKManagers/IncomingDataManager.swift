//
//  IncomingDataManager.swift
//  SKManagers
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import UIKit
import SKAbstractions
import SKStyle
import SKFoundation
import SKUIKit

public protocol IIncomingDataManager: AnyObject {
  var onAppDidBecomeActive: (() -> Void)? { get set }
  var onMyOnlineStatusUpdate: ((AppSettingsModel.Status) -> Void)? { get set }
  var onMessageReceived: ((MessengerNetworkRequestModel, Int32) -> Void)? { get set }
  var onRequestChat: ((MessengerNetworkRequestModel, String) -> Void)? { get set }
  var onFriendOnlineStatusUpdate: ((String, ContactModel.Status) -> Void)? { get set }
  var onIsTypingFriendUpdate: ((String, Bool) -> Void)? { get set }
  var onFriendReadReceipt: ((String, UInt32) -> Void)? { get set }
  var onFileReceive: ((String, URL, Double) -> Void)? { get set }
  var onFileSender: ((String, Double, String) -> Void)? { get set }
  var onFileErrorSender: ((String, String) -> Void)? { get set }
  var onScreenshotTaken: (() -> Void)? { get set }
}


public final class IncomingDataManager: IIncomingDataManager {
  
  // MARK: - Public properties
  
  public static let shared: IIncomingDataManager = IncomingDataManager()
  
  // MARK: - Private properties
  
  public var onAppDidBecomeActive: (() -> Void)?
  public var onMyOnlineStatusUpdate: ((AppSettingsModel.Status) -> Void)?
  public var onMessageReceived: ((MessengerNetworkRequestModel, Int32) -> Void)?
  public var onRequestChat: ((MessengerNetworkRequestModel, String) -> Void)?
  public var onFriendOnlineStatusUpdate: ((String, ContactModel.Status) -> Void)?
  public var onIsTypingFriendUpdate: ((String, Bool) -> Void)?
  public var onFriendReadReceipt: ((String, UInt32) -> Void)?
  public var onFileReceive: ((String, URL, Double) -> Void)?
  public var onFileSender: ((String, Double, String) -> Void)?
  public var onFileErrorSender: ((String, String) -> Void)?
  public var onScreenshotTaken: (() -> Void)?
  
  // MARK: - Init
  
  private init() {
    registerNotifications()
  }
  
  deinit {
    removeNotifications()
  }
}

// MARK: - Private

private extension IncomingDataManager {
  func registerNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleMyOnlineStatus(_:)),
      name: Notification.Name(NotificationConstants.didUpdateMyOnlineStatus.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleMessage(_:)),
      name: Notification.Name(NotificationConstants.didReceiveMessage.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleRequestChat(_:)),
      name: Notification.Name(NotificationConstants.didInitiateChat.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFriendOnlineStatus(_:)),
      name: Notification.Name(NotificationConstants.didUpdateFriendOnlineStatus.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleIsTypingFriend(_:)),
      name: Notification.Name(NotificationConstants.isTyping.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFriendReadReceipt(_:)),
      name: Notification.Name(NotificationConstants.didUpdateFriendReadReceipt.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFileReceive(_:)),
      name: Notification.Name(NotificationConstants.didUpdateFileReceive.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFileSender(_:)),
      name: Notification.Name(NotificationConstants.didUpdateFileSend.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleFileErrorSender(_:)),
      name: Notification.Name(NotificationConstants.didUpdateFileErrorSend.rawValue),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
  }
  
  func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - Handle NotificationCenter

private extension IncomingDataManager {
  @objc func appDidBecomeActive() {
    onAppDidBecomeActive?()
  }
  
  @objc func handleScreenshot() {
    onScreenshotTaken?()
  }
  
  @objc func handleMyOnlineStatus(_ notification: Notification) {
    if let status = notification.userInfo?["onlineStatus"] as? AppSettingsModel.Status {
      onMyOnlineStatusUpdate?(status)
    }
  }
  
  @objc func handleMessage(_ notification: Notification) {
    if let messageModel = notification.userInfo?["data"] as? MessengerNetworkRequestModel,
       let toxFriendId = notification.userInfo?["toxFriendId"] as? Int32 {
      onMessageReceived?(messageModel, toxFriendId)
    }
  }
  
  @objc func handleRequestChat(_ notification: Notification) {
    if let messageModel = notification.userInfo?["requestChat"] as? MessengerNetworkRequestModel,
       let toxPublicKey = notification.userInfo?["toxPublicKey"] as? String {
      onRequestChat?(messageModel, toxPublicKey)
    }
  }
  
  @objc func handleFriendOnlineStatus(_ notification: Notification) {
    if let toxPublicKey = notification.userInfo?["publicKey"] as? String,
       let status = notification.userInfo?["status"] as? ContactModel.Status {
      onFriendOnlineStatusUpdate?(toxPublicKey, status)
    }
  }
  
  @objc func handleIsTypingFriend(_ notification: Notification) {
    if let toxPublicKey = notification.userInfo?["publicKey"] as? String,
       let isTyping = notification.userInfo?["isTyping"] as? Bool {
      onIsTypingFriendUpdate?(toxPublicKey, isTyping)
    }
  }
  
  @objc func handleFriendReadReceipt(_ notification: Notification) {
    if let toxPublicKey = notification.userInfo?["publicKey"] as? String,
       let messageId = notification.userInfo?["messageId"] as? UInt32 {
      onFriendReadReceipt?(toxPublicKey, messageId)
    }
  }
  
  @objc func handleFileReceive(_ notification: Notification) {
    if let publicToxKey = notification.userInfo?["publicKey"] as? String,
       let filePath = notification.userInfo?["filePath"] as? URL,
       let progress = notification.userInfo?["progress"] as? Double {
      onFileReceive?(publicToxKey, filePath, progress)
    }
  }
  
  @objc func handleFileSender(_ notification: Notification) {
    if let toxPublicKey = notification.userInfo?["publicKey"] as? String,
       let progress = notification.userInfo?["progress"] as? Double,
       let messageID = notification.userInfo?["messageID"] as? String {
      onFileSender?(toxPublicKey, progress, messageID)
    }
  }
  
  @objc func handleFileErrorSender(_ notification: Notification) {
    if let toxPublicKey = notification.userInfo?["publicKey"] as? String,
       let messageID = notification.userInfo?["messageID"] as? String {
      onFileErrorSender?(toxPublicKey, messageID)
    }
  }
}
