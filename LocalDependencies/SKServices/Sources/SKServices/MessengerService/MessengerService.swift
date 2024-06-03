//
//  MessengerService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation
import SKAbstractions

public final class MessengerService: IMessengerService {
  public init() {}
  
  /// Возвращает сервис обмена сообщениями.
  public func messagesService(privateKey: String) -> IMessagesService {
    MessagesService(privateKey: privateKey)
  }
}
