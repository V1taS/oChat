//
//  ToxMessageType.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 16.06.2024.
//

import Foundation

/// Перечисление, представляющее типы сообщений в Tox.
/// - `normal`: Обычное текстовое сообщение.
/// - `action`: Сообщение-действие, используемое для обозначения каких-либо действий или событий.
public enum ToxSendMessageType {
  /// Обычное текстовое сообщение.
  case normal
  
  /// Сообщение-действие, используемое для обозначения действий или событий.
  case action
}
