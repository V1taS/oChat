//
//  MessengerNetworkRequestModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 14.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

/// 1 372 байта максимальный размер структуры
/// Структура для представления сетевого запроса в мессенджере oChat.
public struct MessengerNetworkRequestModel: Codable {

  /// ID сообщения
  public let messageID: String

  /// Текст сообщения для отправки.
  public let messageText: String?

  /// Цитируемое сообщение ID
  public let replyMessageText: String?

  /// Реакции, например смайлы
  public let reactions: String?

  /// Набор любых вложений (фото, видео, запись, файл).
  public let attachments: [MediaAttachmentData]?

  /// Локальный адрес в mesh-сети.
  public let meshAddress: String?

  /// Tox 76-символьный адрес друга
  public let toxAddress: String?

  /// Публичный ключ для шифрования сообщений
  public let publicKeyForEncryption: String?

  /// Токен для отправки пушей
  public let pushNotificationToken: String?

  /// Правила для конкретного чата
  public let chatRules: ChatRules
}
