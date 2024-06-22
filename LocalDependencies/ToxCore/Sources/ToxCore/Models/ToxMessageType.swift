//
//  ToxMessageType.swift
//  ToxCore
//
//  Created by Vitalii Sosin on 15.06.2024.
//

import Foundation
import ToxCoreCpp

/// Перечисление, представляющее типы сообщений в Tox.
/// - `normal`: Обычное текстовое сообщение.
/// - `action`: Сообщение-действие, используемое для обозначения каких-либо действий или событий.
public enum ToxMessageType {
  /// Обычное текстовое сообщение.
  case normal
  
  /// Сообщение-действие, используемое для обозначения действий или событий.
  case action
}
