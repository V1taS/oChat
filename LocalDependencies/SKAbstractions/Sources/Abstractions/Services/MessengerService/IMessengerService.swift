//
//  IMessengerService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation

/// Протокол для управления сервисами, связанными с мессенджером
public protocol IMessengerService {
  /// Возвращает сервис обмена сообщениями.
  func messagesService(privateKey: String) -> IMessagesService
}
