//
//  ChatMessage.swift
//  oChat
//
//  Created by Vitalii Sosin on 14.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

/// Модель чата/сообщения
struct ChatMessage: Identifiable, Codable, Equatable {
  // локальный идентификатор для SwiftUI
  let id: UUID

  /// ID сообщения в TOX
  var messageId: UInt32?

  /// ID друга в TOX
  let friendID: UInt32

  /// Текст сообщения.
  var message: String

  /// Цитируемое сообщение
  var replyMessageText: String?

  /// Реакции, например смайлы
  var reactions: String?

  /// Тип сообщения (отправленное или полученное).
  let messageType: MessageType

  /// Дата отправки сообщения
  let date: Date

  /// Статус доставки и чтения сообщения.
  var messageStatus: MessageStatus

  /// Набор любых вложений (фото, видео, запись, файл).
  var attachments: [MediaAttachmentURL]?

  init(
    messageId: UInt32?,
    friendID: UInt32,
    message: String,
    replyMessageText: String?,
    reactions: String?,
    messageType: MessageType,
    date: Date,
    messageStatus: MessageStatus,
    attachments: [MediaAttachmentURL]?
  ) {
    self.id = UUID()
    self.messageId = messageId
    self.friendID = friendID
    self.message = message
    self.replyMessageText = replyMessageText
    self.reactions = reactions
    self.messageType = messageType
    self.date = date
    self.messageStatus = messageStatus
    self.attachments = attachments
  }
}

/// Перечисление, представляющее статусы сообщений
public enum MessageStatus: Codable, Equatable {
  /// Статус отправки сообщения.
  /// Указывает, что сообщение в процессе отправки.
  case sending

  /// Статус ошибки отправки сообщения.
  /// Указывает, что произошла ошибка при отправке сообщения.
  case failed

  /// Статус успешной отправки сообщения.
  /// Указывает, что сообщение было успешно отправлено.
  case sent

  /// Статус успешного прочтения сообщения
  case read
}

/// Тип пользовательского сообщения
enum MessageType: Codable, Equatable {
  /// входящее сообщение
  case incoming
  /// исходящее сообщение
  case outgoing
  /// системное сообщение заданного типа
  case system
}

extension ChatMessage {
  static func mockList(friendID: UInt32, count: Int = 10) -> [ChatMessage] {
    let now = Date()
    let samples = ["Привет! Как дела?",
                   "Все отлично 🙂",
                   "Чем занимаешься?",
                   "Работаю над oChat 🚀",
                   "Звучит круто!"]

    return (0..<count).map { idx -> ChatMessage in
      let text = samples[idx % samples.count]
      let reply = idx == 4 ? "Цитата: \(samples[1])" : nil
      let reaction = idx == 3 ? "👍" : nil
      let type: MessageType

      if idx.isMultiple(of: 3) {
        type = .system
      } else if idx.isMultiple(of: 2) {
        type = .outgoing
      } else {
        type = .incoming
      }

      let date = Calendar.current.date(byAdding: .minute,
                                       value: -(idx * 5),
                                       to: now) ?? now
      let status: MessageStatus =
      type == .outgoing ? (idx % 3 == 0 ? .read : .sent) : .read

      return ChatMessage(
        messageId: UInt32(idx + 1),
        friendID: friendID,
        message: text,
        replyMessageText: reply,
        reactions: reaction,
        messageType: type,
        date: date,
        messageStatus: status,
        attachments: nil
      )
    }
  }

  /// Одиночная «пустышка», удобно использовать,
  /// когда сообщения ещё нет, но UI требует объект.
  static let placeholder = ChatMessage(
    messageId: nil,
    friendID: 0,
    message: "Нет сообщений",
    replyMessageText: nil,
    reactions: nil,
    messageType: .incoming,
    date: .distantPast,
    messageStatus: .sent,
    attachments: nil
  )
}
