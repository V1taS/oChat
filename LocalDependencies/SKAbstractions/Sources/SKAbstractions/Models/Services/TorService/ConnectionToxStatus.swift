//
//  ConnectionToxStatus.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 16.06.2024.
//

import Foundation

/// Перечисление, представляющее статус соединения с другом.
public enum ConnectionToxStatus {
  /// Нет соединения.
  case none
  /// Установлено соединение по TCP.
  case tcp
  /// Установлено соединение по UDP.
  case udp
}
