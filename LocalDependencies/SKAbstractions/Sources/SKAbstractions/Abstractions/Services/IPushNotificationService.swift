//
//  IPushNotificationService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 25.06.2024.
//

import Foundation

/// Протокол для отправки push-уведомлений
public protocol IPushNotificationService {
  /// Метод для отправки push-уведомлений
  /// - Parameters:
  ///   - title: Заголовок уведомления
  ///   - body: Тело уведомления
  ///   - customData: Пользовательские данные, которые будут включены в payload уведомления
  ///   - deviceToken: Токен устройства, на которое будет отправлено уведомление
  func sendPushNotification(title: String, body: String, customData: [String: Any], deviceToken: String)
}
