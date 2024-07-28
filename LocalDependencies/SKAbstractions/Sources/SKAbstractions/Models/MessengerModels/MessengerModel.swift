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
  
  // MARK: - Initializer

  /// Инициализирует новый экземпляр `SafeKeeperModel` с указанными настройками приложения и кошельками.
  /// - Parameters:
  ///   - appSettingsModel: Модель настроек приложения.
  ///   - contacts: Массив моделей контактов, каждый из которых представляет отдельный контакт.
  public init(
    appSettingsModel: AppSettingsModel,
    contacts: [ContactModel]
  ) {
    self.appSettingsModel = appSettingsModel
    self.contacts = contacts
  }
}

// MARK: - Set default values

extension MessengerModel {
  public static func setDefaultValues() -> Self {
    Self(
      appSettingsModel: .setDefaultValues(),
      contacts: []
    )
  }
}

// MARK: - IdentifiableAndCodable

extension MessengerModel: IdentifiableAndCodable {}
