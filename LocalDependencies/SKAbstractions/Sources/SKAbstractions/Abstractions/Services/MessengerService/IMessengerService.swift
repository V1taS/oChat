//
//  IMessengerService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation

/// Протокол для управления сервисами, связанными с мессенджером
public protocol IMessengerService {
  
  /// Управляет чатом P2P через Tor.
  var p2pChatManager: IP2PChatManager { get }
  
  /// Возвращает сервис  для управления настройками модели контакта.
  var modelSettingsManager: IMessengerModelSettingsManager { get }
  
  /// Возвращает сервис для обработки и управления моделями данных в приложении.
  var modelHandlerService: IMessengerModelHandlerService { get }
  
  /// Возвращает сервис для управления настройками приложения.
  /// - Returns: Сервис управления настройками приложения.
  var appSettingsManager: IAppSettingsManager { get }
}
