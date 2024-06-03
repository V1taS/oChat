//
//  MessengerKeyExchangeType.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 10.05.2024.
//

import Foundation

/// Перечисление, представляющее типы сообщений в процессе обмена ключами между двумя клиентами.
public enum MessengerKeyExchangeType {
  /// Старт обмена ключами
  case handshakeStart
  /// Зашифровано (Клиенты обменялись ключами)
  case encryption
}
