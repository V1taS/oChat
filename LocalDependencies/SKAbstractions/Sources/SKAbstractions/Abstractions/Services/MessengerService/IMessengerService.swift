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
  
  /// Возвращает сервис  для управления сообщениями
  var messengeDataManager: IMessengeDataManager { get }
  
  /// Возвращает сервис  для управления контактами
  var contactsDataManager: IContactsDataManager { get }
  
  /// Возвращает сервис  для управления настройками приложения
  var appSettingsDataManager: IAppSettingsDataManager { get }
}
