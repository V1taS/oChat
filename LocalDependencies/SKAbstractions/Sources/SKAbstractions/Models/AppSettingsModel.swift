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
  
  /// Фейковый доступ, можно ввести пароль и откроется пустой чат
  public var fakeAppPassword: String?
  
  /// Тип доступа
  public var accessType: AppSettingsModel.AccessType
  
  /// Токен для отправки пушей
  public var pushNotificationToken: String?
  
  /// Указывает, включены ли уведомления.
  public var isNotificationsEnabled: Bool
  
  /// Мой статус онлайн.
  public var myStatus: AppSettingsModel.Status
  
  /// Строка, содержащая сохранённое состояние Tox в формате Base64
  public var toxStateAsString: String?
  
  /// Премиум режим для доступа к дополнительным функциям
  public var isPremiumEnabled: Bool
  
  /// Показывает, когда я набираю сообщение
  public var isTypingIndicatorEnabled: Bool
  
  /// Разрешить собеседнику сохранять отправленные вами фото и видео
  public var canSaveMedia: Bool
  
  /// Разрешить собеседнику хранить историю переписки
  public var isChatHistoryStored: Bool
  
  /// Измените свой голос при аудиозвонках и в аудиозаписях.
  public var isVoiceChangerEnabled: Bool
  
  /// Инициализирует новый экземпляр `AppSettingsModel`.
  /// - Parameters:
  ///   - appPassword: Строка, представляющая пароль для входа в приложение.
  ///   - fakeAppPassword: Фейковый доступ, можно ввести пароль и откроется пустой чат
  ///   - accessType: Тип доступа
  ///   - pushNotificationToken: Токен для отправки пушей
  ///   - isNotificationsEnabled: Булево значение, указывающее, включены ли уведомления.
  ///   - myStatus: Мой статус онлайн.
  ///   - toxStateAsString: Строка, содержащая сохранённое состояние Tox в формате Base64
  ///   - isPremiumEnabled: Премиум режим для доступа к дополнительным функциям
  ///   - isTypingIndicatorEnabled: Показывает, когда я набираю сообщение
  ///   - canSaveMedia: Разрешить собеседнику сохранять отправленные вами фото и видео
  ///   - isChatHistoryStored: Разрешить собеседнику хранить историю переписки
  ///   - isVoiceChangerEnabled: Измените свой голос при аудиозвонках и в аудиозаписях.
  public init(
    appPassword: String?,
    fakeAppPassword: String?,
    accessType: AppSettingsModel.AccessType,
    pushNotificationToken: String?,
    isNotificationsEnabled: Bool,
    myStatus: AppSettingsModel.Status,
    toxStateAsString: String?,
    isPremiumEnabled: Bool,
    isTypingIndicatorEnabled: Bool,
    canSaveMedia: Bool,
    isChatHistoryStored: Bool,
    isVoiceChangerEnabled: Bool
  ) {
    self.appPassword = appPassword
    self.fakeAppPassword = fakeAppPassword
    self.accessType = accessType
    self.pushNotificationToken = pushNotificationToken
    self.isNotificationsEnabled = isNotificationsEnabled
    self.myStatus = myStatus
    self.toxStateAsString = toxStateAsString
    self.isPremiumEnabled = isPremiumEnabled
    self.isTypingIndicatorEnabled = isTypingIndicatorEnabled
    self.canSaveMedia = canSaveMedia
    self.isChatHistoryStored = isChatHistoryStored
    self.isVoiceChangerEnabled = isVoiceChangerEnabled
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

// MARK: - Status

extension AppSettingsModel {
  /// Перечисление, представляющее различные виды доступа в приложении.
  public enum AccessType {
    /// Демо доступ
    case demo
    
    /// Фейковый доступ
    case fake
    
    /// Основной доступ
    case main
  }
}

// MARK: - Set default values

extension AppSettingsModel {
  public static func setDefaultValues() -> Self {
    return .init(
      appPassword: nil,
      fakeAppPassword: nil,
      accessType: .main,
      pushNotificationToken: nil,
      isNotificationsEnabled: false,
      myStatus: .inProgress,
      toxStateAsString: nil,
      isPremiumEnabled: false,
      isTypingIndicatorEnabled: true,
      canSaveMedia: true,
      isChatHistoryStored: true,
      isVoiceChangerEnabled: true
    )
  }
}

// MARK: - IdentifiableAndCodable

extension AppSettingsModel: IdentifiableAndCodable {}
extension AppSettingsModel.Status: IdentifiableAndCodable {}
extension AppSettingsModel.AccessType: IdentifiableAndCodable {}
