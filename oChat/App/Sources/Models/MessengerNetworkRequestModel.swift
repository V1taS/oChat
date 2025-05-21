//
//  MessengerNetworkRequestModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 14.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

// MARK: - Модель сетевого запроса

/// 1 372 байта максимальный размер структуры
/// Единая структура, описывающая любой исходящий запрос из oChat.
/// Состоит из полезной нагрузки (`payload`) и системных данных (`system`).
public struct MessengerNetworkRequestModel: Codable {

  /// Что именно отправляем (текст, цитату, реакцию, медиа…).
  public let payloads: [Payload]

  /// Адреса, ключи шифрования, правила чата и прочие общие параметры.
  public let system: SystemInfo
}

// MARK: - Payload

extension MessengerNetworkRequestModel {
  /// Возможные типы контента, который можно доставить собеседнику.
  public enum Payload: Codable {
    // MARK: Пользовательские события
    /// Обычное текстовое сообщение.
    /// - Parameters:
    ///   - id: Уникальный ID сообщения.
    ///   - text: Содержимое текста.
    case message(id: String, text: String)

    /// Ответ (reply) на существующее сообщение.
    /// - Parameters:
    ///   - id: Уникальный ID нового сообщения-ответа.
    ///   - quotedMessageID: ID того сообщения, которое цитируем.
    case quote(id: String, quotedMessageID: String)

    /// Реакция (эмодзи) на сообщение.
    /// - Parameters:
    ///   - id: Уникальный ID реакции.
    ///   - value: Текст реакции (например, «👍»).
    case reaction(id: String, value: String)

    /// Медиаконтент (фото, видео, файлы).
    /// - Parameters:
    ///   - id: Уникальный ID сообщения с медиа.
    ///   - attachments: Список вложений.
    case media(id: String, attachments: [MediaAttachmentData])

    /// Системное сообщение (баннер «дружба подтверждена», «история удалена» и т. д.).
    /// - Parameters:
    ///   - id: Уникальный ID системного события.
    ///   - text: Текст системного сообщения.
    case system(id: String, text: String)

    // MARK: Кодирование / декодирование
    private enum CodingKeys: String, CodingKey {
      case type, id, text, quotedMessageID, reaction, attachments
    }
    private enum Kind: String, Codable {
      case message, quote, reaction, media, system
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      switch self {
      case let .message(id, text):
        try container.encode(Kind.message, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)

      case let .quote(id, quoted):
        try container.encode(Kind.quote, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(quoted, forKey: .quotedMessageID)

      case let .reaction(id, value):
        try container.encode(Kind.reaction, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(value, forKey: .reaction)

      case let .media(id, files):
        try container.encode(Kind.media, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(files, forKey: .attachments)

      case let .system(id, text):
        try container.encode(Kind.system, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
      }
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let kind = try container.decode(Kind.self, forKey: .type)

      switch kind {
      case .message:
        self = .message(
          id: try container.decode(String.self, forKey: .id),
          text: try container.decode(String.self, forKey: .text)
        )
      case .quote:
        self = .quote(
          id: try container.decode(String.self, forKey: .id),
          quotedMessageID: try container.decode(String.self, forKey: .quotedMessageID)
        )
      case .reaction:
        self = .reaction(
          id: try container.decode(String.self, forKey: .id),
          value: try container.decode(String.self, forKey: .reaction)
        )
      case .media:
        self = .media(
          id: try container.decode(String.self, forKey: .id),
          attachments: try container.decode([MediaAttachmentData].self, forKey: .attachments)
        )
      case .system:
        self = .system(
          id: try container.decode(String.self, forKey: .id),
          text: try container.decode(String.self, forKey: .text)
        )
      }
    }
  }
}

// MARK: - SystemInfo

extension MessengerNetworkRequestModel {
  public struct SystemInfo: Codable {
    /// Локальный адрес в mesh-сети (если применимо).
    public let meshAddress: String?

    /// TOX-адрес собеседника (76 символов).
    public let toxAddress: String?

    /// Публичный ключ для шифрования сообщения.
    public let publicKeyForEncryption: String?

    /// Токен APNs для отправки push-уведомления.
    public let pushNotificationToken: String?

    /// Правила конкретного чата (например, auto-delete, запрет скриншотов).
    public let chatRules: ChatRules

    /// Инициализатор системных данных.
    public init(
      meshAddress: String?,
      toxAddress: String?,
      publicKeyForEncryption: String?,
      pushNotificationToken: String?,
      chatRules: ChatRules = .init()
    ) {
      self.meshAddress = meshAddress
      self.toxAddress = toxAddress
      self.publicKeyForEncryption = publicKeyForEncryption
      self.pushNotificationToken = pushNotificationToken
      self.chatRules = chatRules
    }
  }
}
