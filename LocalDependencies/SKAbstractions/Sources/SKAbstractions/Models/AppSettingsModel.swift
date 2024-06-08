//
//  AppSettingsModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 17.05.2024.
//

import Foundation

/// Модель, представляющая настройки приложения.
public struct AppSettingsModel {
  
  /// Указывает, включена ли разблокировка по FaceID.
  public var isFaceIDEnabled: Bool
  
  /// Пароль для входа в приложение.
  public var appPassword: String?
  
  /// Указывает, включены ли уведомления.
  public var isNotificationsEnabled: Bool
  
  /// Инициализирует новый экземпляр `AppSettingsModel`.
  /// - Parameters:
  ///   - isFaceIDEnabled: Булево значение, указывающее, включена ли разблокировка по FaceID.
  ///   - appPassword: Строка, представляющая пароль для входа в приложение.
  ///   - isNotificationsEnabled: Булево значение, указывающее, включены ли уведомления.
  public init(
    isFaceIDEnabled: Bool,
    appPassword: String?,
    isNotificationsEnabled: Bool
  ) {
    self.isFaceIDEnabled = isFaceIDEnabled
    self.appPassword = appPassword
    self.isNotificationsEnabled = isNotificationsEnabled
  }
}

// MARK: - Set default values

extension AppSettingsModel {
  public static func setDefaultValues() -> Self {
    return .init(
      isFaceIDEnabled: false,
      appPassword: nil,
      isNotificationsEnabled: false
    )
  }
}

// MARK: - IdentifiableAndCodable

extension AppSettingsModel: IdentifiableAndCodable {}
