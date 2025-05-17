//
//  ConnectionState.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 07.05.2025.
//

import Foundation
import CTox
import CSodium

// MARK: – Состояние соединения (Swift‑friendly)

/// Текущее состояние соединения (для себя или конкретного друга).
public enum ToxConnectionState: Sendable {
  /// Нет соединения — пользователь (или друг) офлайн.
  case none
  /// Соединение через TCP‑relay.
  case tcp
  /// Прямое UDP‑соединение.
  case udp

  // MARK: – Маппинг на/из C‑enumeration

  /// Соответствующее C‑значение, пригодное для передачи в toxcore.
  public var cValue: TOX_CONNECTION {
    switch self {
    case .none: return TOX_CONNECTION_NONE
    case .tcp:  return TOX_CONNECTION_TCP
    case .udp:  return TOX_CONNECTION_UDP
    }
  }

  /// Инициализатор из C‑значения (при получении данных из toxcore).
  public init?(cValue: TOX_CONNECTION) {
    switch cValue {
    case TOX_CONNECTION_NONE: self = .none
    case TOX_CONNECTION_TCP: self = .tcp
    case TOX_CONNECTION_UDP: self = .udp
    default: return nil
    }
  }
}
