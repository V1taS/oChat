//
//  MessengerNetworkRequestModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import Foundation

/// Структура для представления сетевого запроса в мессенджере oChat.
public struct MessengerNetworkRequestModel {
  
  /// Текст сообщения, которое необходимо отправить другому пользователю.
  public var messageText: String?
  
  /// ID сообщения
  public var messageID: String?
  
  /// Цитируемое сообщение
  public var replyMessageText: String?
  
  /// Адрес получателя в сети Tor для доставки сообщения.
  public let senderAddress: String
  
  /// Адрес получателя в локальной mesh-сети, используемый для отправки сообщений при отсутствии интернета.
  public let senderLocalMeshAddress: String?
  
  /// Публичный ключ отправителя для верификации его подлинности получателем.
  public let senderPublicKey: String?
  
  /// Публичный ключ для шифрования сообщений.
  public var senderToxPublicKey: String?
  
  /// Токен для отправки пушей
  public var senderPushNotificationToken: String?
  
  /// Инициализирует новый экземпляр сетевого запроса для мессенджера с заданными параметрами.
  /// - Parameters:
  ///   - messageText: Текст сообщения.
  ///   - messageID: ID сообщения
  ///   - replyMessageText: Цитируемое сообщение
  ///   - senderAddress: Адрес в сети для отправки.
  ///   - senderLocalMeshAddress: Адрес в локальной сети для отправки.
  ///   - senderPublicKey: Публичный ключ отправителя.
  ///   - senderToxPublicKey: Публичный ключ для шифрования сообщений.
  ///   - senderPushNotificationToken: Токен для отправки пушей
  public init(
    messageText: String?,
    messageID: String?,
    replyMessageText: String?,
    senderAddress: String,
    senderLocalMeshAddress: String?,
    senderPublicKey: String?,
    senderToxPublicKey: String?,
    senderPushNotificationToken: String?
  ) {
    self.messageText = messageText
    self.messageID = messageID
    self.replyMessageText = replyMessageText
    self.senderAddress = senderAddress
    self.senderLocalMeshAddress = senderLocalMeshAddress
    self.senderPublicKey = senderPublicKey
    self.senderToxPublicKey = senderToxPublicKey
    self.senderPushNotificationToken = senderPushNotificationToken
  }
}

// MARK: - Mapping

extension MessengerNetworkRequestModel {
  /// Преобразует модель запроса в объект передачи данных (DTO).
  public func mapToDTO() -> MessengerNetworkRequestDTO {
    MessengerNetworkRequestDTO(
      messageText: messageText, 
      messageID: messageID,
      replyMessageText: replyMessageText,
      senderAddress: senderAddress,
      senderLocalMeshAddress: senderLocalMeshAddress,
      senderPublicKey: senderPublicKey,
      senderToxPublicKey: senderToxPublicKey, 
      senderPushNotificationToken: senderPushNotificationToken
    )
  }
}

// MARK: - IdentifiableAndCodable

extension MessengerNetworkRequestModel: IdentifiableAndCodable {}
