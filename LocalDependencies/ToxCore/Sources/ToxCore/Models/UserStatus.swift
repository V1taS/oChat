//
//  UserStatus.swift
//
//
//  Created by Vitalii Sosin on 10.06.2024.
//

import Foundation
import ToxCoreCpp

/// Перечисление для статусов пользователя.
/// - online: Пользователь в сети и доступен.
/// - away: Пользователь отсутствует. Клиенты могут установить этот статус, например, после заданного времени неактивности.
/// - busy: Пользователь занят и не хочет общаться в данный момент.
public enum UserStatus {
  /// Пользователь в сети и доступен.
  case online
  
  /// Пользователь отсутствует. Клиенты могут установить этот статус, например, после заданного времени неактивности.
  case away
  
  /// Пользователь занят и не хочет общаться в данный момент.
  case busy
  
  /// Преобразует статус из C в Swift-совместимое перечисление `UserStatus`.
  /// - Parameter cStatus: Статус из библиотеки Tox.
  /// - Returns: Соответствующий статус в виде `UserStatus`.
  static func userStatusFromCUserStatus(_ cStatus: TOX_USER_STATUS) -> UserStatus? {
    switch cStatus {
    case TOX_USER_STATUS_NONE:
      return .online
    case TOX_USER_STATUS_AWAY:
      return .away
    case TOX_USER_STATUS_BUSY:
      return .busy
    default:
      return nil
    }
  }
}
