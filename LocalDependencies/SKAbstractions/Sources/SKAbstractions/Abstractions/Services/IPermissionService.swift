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
  /// - Parameter granted: Булево значение, указывающее, было ли предоставлено разрешение
  func requestNotification(completion: @escaping (_ granted: Bool) -> Void)

  /// Метод для проверки, включены ли уведомления
  /// - Parameter enabled: Булево значение, указывающее, было ли включено уведомление
  func isNotificationsEnabled(completion: @escaping (_ enabled: Bool) -> Void)
  
  /// Запрос доступа к Камере
  /// - Parameter granted: Булево значение, указывающее, было ли предоставлено разрешение
  func requestCamera(completion: @escaping (_ granted: Bool) -> Void)
  
  /// Запрос доступа к Галерее
  /// - Parameter granted: Булево значение, указывающее, было ли предоставлено разрешение
  func requestGallery(completion: @escaping (_ granted: Bool) -> Void)
  
  /// Запрос доступа к Face ID для аутентификации
  /// - Parameter granted: Булево значение, указывающее, было ли предоставлено разрешение
  func requestFaceID(completion: @escaping (_ granted: Bool) -> Void)
}
