//
//  NotificationConstants.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import Foundation

public enum NotificationConstants: String {
  /// Отправка уведомления о получении нового сообщения
  case didReceiveMessage
  /// Имя для получения уведомлений о начале переписки
  case didInitiateChat
  /// Онлайн мой статус
  case didUpdateMyOnlineStatus
  /// Состояние ТОР
  case sessionState
  /// Онлайн статус друзей
  case didUpdateFriendOnlineStatus
}
