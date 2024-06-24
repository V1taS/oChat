//
//  MessageView+Model.swift
//  oChat
//
//  Created by Vitalii Sosin on 24.06.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKStyle
import SKAbstractions

// MARK: - Model

extension MessageView {
  /// Структура модели для отображения сообщения в `MessageView`.
  public struct Model: Identifiable, Hashable {
    
    // MARK: - Public properties
    
    /// Уникальный идентификатор сообщения.
    public var id: String
    
    /// Текст сообщения.
    public var text: String
    
    /// Тип сообщения (входящее или исходящее).
    public let messageType: MessageView.MessageType
    
    /// Статус сообщения
    public let messageStatus: MessageStatus
    
    /// Флаг, указывающий наличие "хвостика" у сообщения.
    public let hasTail: Bool
    
    /// Экшен для удаления сообщения.
    public var deleteAction: (() -> Void)?
    
    /// Экшен для копирования текста сообщения.
    public var copyAction: (() -> Void)?
    
    /// Экшен для повторной отправки сообщения
    public var retrySendAction: (() -> Void)?
    
    // MARK: - Init
    
    /// Инициализатор для создания новой модели сообщения.
    /// - Parameters:
    ///  - id: Уникальный идентификатор сообщения.
    ///  - text: Текст сообщения.
    ///  - messageType: Тип сообщения (`.incoming` для входящих сообщений и `.outgoing` для исходящих).
    ///  - messageStatus: Статус сообщения
    ///  - hasTail: Флаг, указывающий наличие "хвостика" у сообщения.
    ///  - deleteAction: Опциональный экшен для удаления сообщения.
    ///  - copyAction: Опциональный экшен для копирования текста сообщения.
    ///  - retrySendAction: Экшен для повторной отправки сообщения
    public init(
      id: String,
      text: String,
      messageType: MessageView.MessageType,
      messageStatus: MessageStatus = .sent,
      hasTail: Bool = false,
      deleteAction: (() -> Void)? = nil,
      copyAction: (() -> Void)? = nil,
      retrySendAction: (() -> Void)? = nil
    ) {
      self.id = id
      self.text = text
      self.messageType = messageType
      self.messageStatus = messageStatus
      self.hasTail = hasTail
      self.deleteAction = deleteAction
      self.copyAction = copyAction
      self.retrySendAction = retrySendAction
    }
  }
}

// MARK: - Model

extension MessageView {
  /// Перечисление типов сообщений.
  public enum MessageType: Hashable {
    /// Цвет фона
    var backgroundColor: Color {
      switch self {
      case .incoming:
        return SKStyleAsset.constantNavy.swiftUIColor
      case .outgoing:
        return SKStyleAsset.constantAzure.swiftUIColor
      }
    }
    
    /// Цвет текста
    var foregraundColor: Color {
      switch self {
      case .incoming:
        SKStyleAsset.constantGhost.swiftUIColor
      case .outgoing:
        SKStyleAsset.constantGhost.swiftUIColor
      }
    }
    
    /// Входящее сообщение.
    case incoming
    
    /// Исходящее сообщение.
    case outgoing
  }
}

// MARK: - MessageStatus

extension MessageView {
  /// Перечисление, представляющее различные статусы сообщения.
  /// Используется для определения текущего состояния сообщения.
  public enum MessageStatus: Hashable {
    /// Статус отправки сообщения.
    /// Указывает, что сообщение в процессе отправки.
    case sending
    
    /// Статус ошибки отправки сообщения.
    /// Указывает, что произошла ошибка при отправке сообщения.
    case failed
    
    /// Статус успешной отправки сообщения.
    /// Указывает, что сообщение было успешно отправлено.
    case sent
    
    /// Статус вью у сообщения
    var statusView: AnyView {
      switch self {
      case .sending:
        return AnyView(SendingMessageView())
      case .failed:
        return AnyView(FailedMessageView())
      case .sent:
        return AnyView(SentMessageView())
      }
    }
  }
}

// MARK: - Hashable

public extension MessageView.Model {
  static func ==(lhs: MessageView.Model, rhs: MessageView.Model) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

// MARK: - Mapping

extension MessengeModel.MessageStatus {
  public func mapTo() -> MessageView.MessageStatus {
    switch self {
    case .sending:
      return .sending
    case .failed:
      return .failed
    case .sent:
      return .sent
    }
  }
}
