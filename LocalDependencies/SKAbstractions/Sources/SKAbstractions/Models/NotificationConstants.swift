//
//  NotificationConstants.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import Foundation

public enum NotificationConstants {
  /// Имя для получения уведомлений о входящих сообщений
  public static var didReceiveMessageName = "didReceiveMessage"
  /// Имя для получения уведомлений о начале переписки
  public static var didInitiateChatName = "didInitiateMessage"
  /// Онлайн мой статус
  public static var didUpdateOnlineStatusName = "didUpdateOnlineStatusName"
  /// Обновить список контактов на главном экране
  public static var updateListContacts = "updateListContacts"
  /// Состояние ТОР
  public static var sessionState = "sessionState"
  /// Состояние сервера
  public static var serverState = "serverState"
}

