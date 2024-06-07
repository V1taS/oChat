//
//  UserInterfaceAndExperienceService.swift
//  oChat
//
//  Created by Vitalii Sosin on 31.05.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKAbstractions
import SKServices

// MARK: - UserInterfaceAndExperienceService

final class UserInterfaceAndExperienceService: IUserInterfaceAndExperienceService {
  
  // MARK: - Properties
  
  /// Возвращает сервис для работы с UI в приложении.
  var uiService: IUIService {
    UIService()
  }
  
  /// Возвращает сервис для работы с системными службами.
  var systemService: ISystemService {
    SystemService()
  }
  
  /// Возвращает сервис уведомлений.
  var notificationService: INotificationService {
    NotificationService()
  }
  
  /// Возвращает сервис deepLink.
  /// - Returns: Сервис deepLink.
  var deepLinkService: IDeepLinkService {
    deepLinkServiceImpl
  }
}

private let deepLinkServiceImpl = DeepLinkService()
