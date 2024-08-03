//
//  NotificationManager.swift
//  SKManagers
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle
import SKFoundation

public final class NotificationManager: INotificationManager {
  
  // MARK: - Private properties
  
  private let permissionService: IPermissionService
  private let pushNotificationService: IPushNotificationService
  private let p2pChatManager: IP2PChatManager
  private let modelSettingsManager: IMessengerModelSettingsManager
  private let modelHandlerService: IMessengerModelHandlerService
  
  // MARK: - Init
  
  public init(
    permissionService: IPermissionService,
    pushNotificationService: IPushNotificationService,
    p2pChatManager: IP2PChatManager,
    modelSettingsManager: IMessengerModelSettingsManager,
    modelHandlerService: IMessengerModelHandlerService
  ) {
    self.permissionService = permissionService
    self.pushNotificationService = pushNotificationService
    self.p2pChatManager = p2pChatManager
    self.modelSettingsManager = modelSettingsManager
    self.modelHandlerService = modelHandlerService
  }
  
  public func requestNotification() async -> Bool {
    return await permissionService.requestNotification()
  }
  
  public func isNotificationsEnabled() async -> Bool {
    return await permissionService.isNotificationsEnabled()
  }
  
  public func sendPushNotification(contact: ContactModel) async {
    guard let pushNotificationToken = contact.pushNotificationToken else {
      // Handle missing token case
      return
    }
    
    let myToxAddress = await p2pChatManager.getToxAddress()
    guard let myToxAddress else {
      return
    }
    
    let name = myToxAddress.formatString(minTextLength: 10)
    pushNotificationService.sendPushNotification(
      title: "Вас зовут в чат!",
      body: "Ваш контакт \(name) хочет с вами пообщаться. Пожалуйста, зайдите в чат.",
      customData: ["toxAddress": contact.toxAddress ?? ""],
      deviceToken: pushNotificationToken
    )
  }
  
  public func saveMyPushNotificationToken(_ token: String) async {
    await modelSettingsManager.saveMyPushNotificationToken(token)
  }
  
  public func getPushNotificationToken() async -> String? {
    return await modelHandlerService.getMessengerModel().appSettingsModel.pushNotificationToken
  }
}
