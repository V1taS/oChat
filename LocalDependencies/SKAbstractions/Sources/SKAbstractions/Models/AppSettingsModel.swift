//
//  AppSettingsModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 17.05.2024.
//

import Foundation

/// Модель, представляющая настройки приложения.
public struct AppSettingsModel {
  
  /// Пароль для входа в приложение.
  public var appPassword: String?
  
  /// Указывает, включены ли уведомления.
  public var isNotificationsEnabled: Bool
  
  /// Мой статус онлайн.
  public var myStatus: AppSettingsModel.Status

  /// Строка, содержащая сохранённое состояние Tox в формате Base64
  public var toxStateAsString: String?
  
  /// Токен для отправки пушей
  public var pushNotificationToken: String?
  
  /// Инициализирует новый экземпляр `AppSettingsModel`.
  /// - Parameters:
  ///   - appPassword: Строка, представляющая пароль для входа в приложение.
  ///   - isNotificationsEnabled: Булево значение, указывающее, включены ли уведомления.
  ///   - myStatus: Мой статус онлайн.
  ///   - toxStateAsString: Строка, содержащая сохранённое состояние Tox в формате Base64
  ///   - pushNotificationToken: Токен для отправки пушей
  public init(
    appPassword: String?,
    isNotificationsEnabled: Bool,
    myStatus: AppSettingsModel.Status,
    toxStateAsString: String?,
    pushNotificationToken: String?
  ) {
    self.appPassword = appPassword
    self.isNotificationsEnabled = isNotificationsEnabled
    self.myStatus = myStatus
    self.toxStateAsString = toxStateAsString
    self.pushNotificationToken = pushNotificationToken
  }
}

// MARK: - Status

extension AppSettingsModel {
  /// Перечисление, представляющее статусы.
  public enum Status: String {
    /// Пользователь в сети.
    case online

    /// Пользователь не в сети.
    case offline

    /// Пользователь подключается к сети
    case inProgress

    /// Заголовок
    public var title: String {
      switch self {
      case .online:
        AbstractionsStrings.SKAbstractionsLocalization.commonStatusTitleOnline
      case .offline:
        AbstractionsStrings.SKAbstractionsLocalization.commonStatusTitleOffline
      case .inProgress:
        AbstractionsStrings.SKAbstractionsLocalization.messengerModelStatusTitleConnecting
      }
    }
  }
}

// MARK: - Set default values

extension AppSettingsModel {
  public static func setDefaultValues() -> Self {
    return .init(
      appPassword: nil,
      isNotificationsEnabled: false,
      myStatus: .inProgress,
      toxStateAsString: nil,
      pushNotificationToken: nil
    )
  }
}

// MARK: - IdentifiableAndCodable

extension AppSettingsModel: IdentifiableAndCodable {}
extension AppSettingsModel.Status: IdentifiableAndCodable {}
