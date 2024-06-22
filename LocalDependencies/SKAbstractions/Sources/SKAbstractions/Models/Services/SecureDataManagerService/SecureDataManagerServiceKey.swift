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
  /// Контайнер для моделек Мессенджера
  case messengerModelHandler = "MessengerModelHandlerService"
  /// Контейнер с диплинками
  case deepLinkService = "DeepLinkService"
  /// Контейнер для сервиса ТОР
  case torService = "TorService"
}

// MARK: - Extension

extension SecureDataManagerServiceKey {
  /// Элементы которые надо очищать при удалении программы с устройства
  static public var itemsToClear: [SecureDataManagerServiceKey] {
    [.modelHandler, .session, .messengerModelHandler, deepLinkService, torService]
  }
}
