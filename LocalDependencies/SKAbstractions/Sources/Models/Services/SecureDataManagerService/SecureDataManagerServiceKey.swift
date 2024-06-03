//
//  SecureDataManagerServiceKey.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 22.05.2024.
//

import Foundation

public enum SecureDataManagerServiceKey: String {
  /// Контайнер для моделек
  case modelHandler = "ModelHandlerService"
  /// Контайнер для сессий
  case session = "SessionService"
  /// Контайнер для конфигураций приложения CloudKit
  case configurationSecrets = "ConfigurationSecrets"
}

// MARK: - Extension

extension SecureDataManagerServiceKey {
  /// Элементы которые надо очищать при удалении программы с устройства
  static public var itemsToClear: [SecureDataManagerServiceKey] {
    [.modelHandler, .session]
  }
}
