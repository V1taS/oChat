//
//  INotificationService.swift
//
//
//  Created by Vitalii Sosin on 27.02.2024.
//

import Foundation

/// Сервиса уведомлений
public protocol INotificationService {
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  ///   - action: Действие по нажатию на баннер
  func showNotification(_ type: NotificationServiceType, action: (() -> Void)?)
  
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
}
