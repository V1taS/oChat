//
//  MessengerModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 05.06.2024.
//

import SwiftUI

/// Модель `MessengerModel` представляет основную структуру данных для хранения информации о мессанджере и настройках приложения.
/// Эта структура обеспечивает централизованное управление данными, связанными с пользовательскими кошельками и настройками приложения.
public struct MessengerModel {

  // MARK: - Public properties

  /// Модель настроек приложения, содержащая различные пользовательские и системные настройки.
  public var appSettingsModel: AppSettingsModel

  /// Массив моделей контактов, каждый из которых представляет отдельный контакт.
  public var contacts: [ContactModel]

  /// Мой статус онлайн.
  public var myStatus: MessengerModel.Status

  /// Строка, содержащая сохранённое состояние Tox в формате Base64
  public var toxStateAsString: String?
  
  /// Токен для отправки пушей
  public var pushNotificationToken: String?
  
  // MARK: - Initializer

  /// Инициализирует новый экземпляр `SafeKeeperModel` с указанными настройками приложения и кошельками.
  /// - Parameters:
  ///   - appSettingsModel: Модель настроек приложения.
  ///   - contacts: Массив моделей контактов, каждый из которых представляет отдельный контакт.
  ///   - myStatus: Мой статус онлайн.
  ///   - toxStateAsString: Строка, содержащая сохранённое состояние Tox в формате Base64
  ///   - pushNotificationToken: Токен для отправки пушей
  public init(
    appSettingsModel: AppSettingsModel,
    contacts: [ContactModel],
    myStatus: MessengerModel.Status,
    toxStateAsString: String?,
    pushNotificationToken: String?
  ) {
    self.appSettingsModel = appSettingsModel
    self.contacts = contacts
    self.myStatus = myStatus
    self.toxStateAsString = toxStateAsString
    self.pushNotificationToken = pushNotificationToken
  }
}

// MARK: - Status

extension MessengerModel {
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
        AbstractionsStrings.SKAbstractionsLocalization.messengerModelStatusTitleOnline
      case .offline:
        AbstractionsStrings.SKAbstractionsLocalization.messengerModelStatusTitleOffline
      case .inProgress:
        AbstractionsStrings.SKAbstractionsLocalization.messengerModelStatusTitleConnecting
      }
    }
  }
}

// MARK: - Set default values

extension MessengerModel {
  public static func setDefaultValues() -> Self {
    Self(
      appSettingsModel: .setDefaultValues(),
      contacts: [],
      myStatus: .inProgress,
      toxStateAsString: nil, 
      pushNotificationToken: nil
    )
  }
}

// MARK: - IdentifiableAndCodable

extension MessengerModel: IdentifiableAndCodable {}
extension MessengerModel.Status: IdentifiableAndCodable {}
