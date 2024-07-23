//
//  IPermissionService.swift
//
//
//  Created by Vitalii Sosin on 26.02.2024.
//

import Foundation

/// Сервиса запроса доступов
public protocol IPermissionService {
  /// Запрос доступа к Уведомлениям
  /// - Parameter return: Булево значение, указывающее, было ли предоставлено разрешение
  @discardableResult
  func requestNotification() async -> Bool
  
  /// Метод для проверки, включены ли уведомления
  /// - Parameter return: Булево значение, указывающее, было ли включено уведомление
  @discardableResult
  func isNotificationsEnabled() async -> Bool
  
  /// Запрос доступа к Камере
  /// - Parameter return: Булево значение, указывающее, было ли предоставлено разрешение
  @discardableResult
  func requestCamera() async -> Bool
  
  /// Запрос доступа к Галерее
  /// - Parameter return: Булево значение, указывающее, было ли предоставлено разрешение
  @discardableResult
  func requestGallery() async -> Bool
  
  /// Запрос доступа к Face ID для аутентификации
  /// - Parameter return: Булево значение, указывающее, было ли предоставлено разрешение
  @discardableResult
  func requestFaceID() async -> Bool
}
