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
  private let appSettingsDataManager: IAppSettingsDataManager
  
  // MARK: - Init
  
  public init(
    permissionService: IPermissionService,
    pushNotificationService: IPushNotificationService,
    appSettingsDataManager: IAppSettingsDataManager
  ) {
    self.permissionService = permissionService
    self.pushNotificationService = pushNotificationService
    self.appSettingsDataManager = appSettingsDataManager
  }
  
  public func requestNotification() async -> Bool {
    return await permissionService.requestNotification()
  }
  
  public func isNotificationsEnabled() async -> Bool {
    return await permissionService.isNotificationsEnabled()
  }
  
  public func sendPushNotification(contact: ContactModel, title: String, body: String) async {
    guard let pushNotificationToken = contact.pushNotificationToken else {
      // Handle missing token case
      return
    }
    
    pushNotificationService.sendPushNotification(
      title: title,
      body: body,
      customData: [
        "toxAddress": contact.toxAddress ?? "",
        "contactID": contact.id
      ],
      deviceToken: pushNotificationToken
    )
  }
  
  public func saveMyPushNotificationToken(_ token: String) async {
    await appSettingsDataManager.saveMyPushNotificationToken(token)
  }
  
  public func getPushNotificationToken() async -> String? {
    return await appSettingsDataManager.getAppSettingsModel().pushNotificationToken
  }
}
