//
//  IncomingMessage.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 07.05.2025.
//  Обновлено: 07.05.2025.
//

import Foundation
import CTox
import CSodium

// MARK: – Входящее сообщение

/// Модель представления входящего сообщения от друга.
public struct IncomingMessage: Sendable {
  /// Идентификатор друга.
  public let friendID: UInt32
  /// Внутренний вид сообщения.
  public let kind: MessageKind
  /// Текст сообщения (UTF‑8).
  public let text: String

  /// Нативное C‑значение, если нужно передать его обратно в toxcore.
  public var cType: TOX_MESSAGE_TYPE { kind.cValue }

  public init(friendID: UInt32, kind: MessageKind, text: String) {
    self.friendID = friendID
    self.kind = kind
    self.text = text
  }

  public init(friendID: UInt32, kind: TOX_MESSAGE_TYPE, text: String) {
    self.friendID = friendID
    self.kind = MessageKind(cValue: kind) ?? .normal
    self.text = text
  }
}

// MARK: – Тип сообщения (Swift‑friendly)

/// Человекочитаемый тип входящего/исходящего сообщения.
public enum MessageKind: Sendable {
  /// Обычное текстовое сообщение.
  case normal
  /// Сообщение‑действие (аналог IRC `/me`).
  case action

  /// Сопоставление с C‑значением `TOX_MESSAGE_TYPE`.
  var cValue: TOX_MESSAGE_TYPE {
    switch self {
    case .normal: return TOX_MESSAGE_TYPE_NORMAL
    case .action: return TOX_MESSAGE_TYPE_ACTION
    }
  }

  /// Инициализатор из C‑значения (для коллбеков toxcore).
  public init?(cValue: TOX_MESSAGE_TYPE) {
    switch cValue {
    case TOX_MESSAGE_TYPE_NORMAL:  self = .normal
    case TOX_MESSAGE_TYPE_ACTION:  self = .action
    default: return nil
    }
  }
}
