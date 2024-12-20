//
//  ConnectionStatus.swift
//
//
//  Created by Vitalii Sosin on 10.06.2024.
//

import Foundation
import ToxCoreCpp

/// Перечисление, представляющее статус соединения с другом.
public enum ConnectionStatus {
  /// Нет соединения.
  case none
  /// Установлено соединение по TCP.
  case tcp
  /// Установлено соединение по UDP.
  case udp
  
  /// Инициализатор для создания `ConnectionStatus` из `TOX_CONNECTION`.
  /// - Parameter toxConnection: Статус соединения `TOX_CONNECTION`.
  init(from toxConnection: TOX_CONNECTION) {
    switch toxConnection {
    case TOX_CONNECTION_NONE:
      self = .none
    case TOX_CONNECTION_TCP:
      self = .tcp
    case TOX_CONNECTION_UDP:
      self = .udp
    default:
      self = .none
    }
  }
  
  /// Преобразует статус подключения из C в Swift-совместимое перечисление `ConnectionStatus`.
  /// - Parameter cStatus: Статус подключения из библиотеки Tox.
  /// - Returns: Соответствующий статус в виде `ConnectionStatus`.
  static func fromCConnectionStatus(_ cStatus: TOX_CONNECTION) -> ConnectionStatus? {
    switch cStatus {
    case TOX_CONNECTION_NONE:
      return .none
    case TOX_CONNECTION_TCP:
      return .tcp
    case TOX_CONNECTION_UDP:
      return .udp
    default:
      return nil
    }
  }
}
