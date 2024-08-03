//
//  INotificationManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import Foundation

/// Протокол для управления уведомлениями.
public protocol INotificationManager {
  /// Запрашивает разрешение на отправку уведомлений.
  /// - Returns: `true`, если разрешение получено, иначе `false`.
  func requestNotification() async -> Bool
  
  /// Проверяет, включены ли уведомления.
  /// - Returns: `true`, если уведомления включены, иначе `false`.
  func isNotificationsEnabled() async -> Bool
  
  /// Отправляет push-уведомление контакту.
  /// - Parameter contact: Модель контакта.
  func sendPushNotification(contact: ContactModel) async
  
  /// Сохраняет токен для push-уведомлений.
  /// - Parameter token: Токен push-уведомлений.
  func saveMyPushNotificationToken(_ token: String) async
  
  /// Возвращает токен для push-уведомлений.
  /// - Returns: Токен push-уведомлений или nil, если токен отсутствует.
  func getPushNotificationToken() async -> String?
}
