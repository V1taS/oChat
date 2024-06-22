//
//  MessengeModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 05.06.2024.
//

import Foundation

/// Модель сообщения для чата.
public struct MessengeModel {
  /// Уникальный идентификатор сообщения.
  public let id: String
  /// Тип сообщения (отправленное или полученное).
  public let messageType: MessageType
  /// Статус доставки и чтения сообщения.
  public var messageStatus: MessageStatus
  /// Текст сообщения.
  public var message: String
  /// Прикреплённый файл в виде данных (опционально).
  public let file: Data?
  /// Дата отправки сообщения
  public let date: Date
  
  /// Инициализирует новый экземпляр сообщения.
  /// - Parameters:
  ///   - messageType: Тип сообщения (отправленное или полученное).
  ///   - messageStatus: Статус доставки и чтения сообщения.
  ///   - message: Текст сообщения.
  ///   - file: Прикреплённый файл в виде данных (опционально).
  public init(
    messageType: MessageType,
    messageStatus: MessageStatus,
    message: String,
    file: Data? = nil
  ) {
    self.messageType = messageType
    self.messageStatus = messageStatus
    self.message = message
    self.file = file
    self.id = UUID().uuidString
    self.date = Date()
  }
}

// MARK: - MessengeType

extension MessengeModel {
  /// Перечисление типов сообщений в чате.
  public enum MessageType {
    /// Сообщение отправлено мною
    case own
    /// Сообщение получено от другого пользователя.
    case received
    /// Системное сообщение
    case system
  }
}

// MARK: - MessengeType

extension MessengeModel {
  /// Перечисление, представляющее статусы сообщений
  public enum MessageStatus {
    /// Сообщение не отправлено
    case notSent
    /// В процессе отправки
    case inProgress
    /// Сообщение отправлено
    case sent
    /// Сообщение доставлено
    case delivered
    /// Сообщение прочитано
    case read
  }
}

// MARK: - IdentifiableAndCodable

extension MessengeModel: IdentifiableAndCodable {}
extension MessengeModel.MessageType: IdentifiableAndCodable {}
extension MessengeModel.MessageStatus: IdentifiableAndCodable {}
