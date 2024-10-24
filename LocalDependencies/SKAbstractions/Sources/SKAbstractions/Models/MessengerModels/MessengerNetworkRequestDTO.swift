//
//  MessengerNetworkRequestDTO.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 07.06.2024.
//

import Foundation

/// Структура для представления сетевого запроса в мессенджере oChat.
public struct MessengerNetworkRequestDTO {
  
  /// Текст сообщения для отправки.
  public var messageText: String?
  
  /// ID сообщения
  public var messageID: String?
  
  /// Цитируемое сообщение ID
  public var replyMessageText: String?
  
  /// Адрес получателя в сети для доставки сообщения.
  public let senderAddress: String
  
  /// Адрес получателя в локальной mesh-сети для отправки сообщений при отсутствии интернета.
  public let senderLocalMeshAddress: String?
  
  /// Публичный ключ отправителя для верификации его подлинности получателем.
  public let senderPublicKey: String?
  
  /// Публичный ключ для шифрования сообщений.
  public var senderToxPublicKey: String?
  
  /// Токен для отправки пушей
  public var senderPushNotificationToken: String?
  
  /// Разрешить собеседнику сохранять отправленные вами фото и видео
  public var canSaveMedia: Bool
  
  /// Разрешить собеседнику хранить историю переписки
  public var isChatHistoryStored: Bool
  
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
  ///   - canSaveMedia: Разрешить собеседнику сохранять отправленные вами фото и видео
  ///   - isChatHistoryStored: Разрешить собеседнику хранить историю переписки
  public init(
    messageText: String?,
    messageID: String?,
    replyMessageText: String?,
    senderAddress: String,
    senderLocalMeshAddress: String?,
    senderPublicKey: String?,
    senderToxPublicKey: String?,
    senderPushNotificationToken: String?,
    canSaveMedia: Bool,
    isChatHistoryStored: Bool
  ) {
    self.messageText = messageText
    self.messageID = messageID
    self.replyMessageText = replyMessageText
    self.senderAddress = senderAddress
    self.senderLocalMeshAddress = senderLocalMeshAddress
    self.senderPublicKey = senderPublicKey
    self.senderToxPublicKey = senderToxPublicKey
    self.senderPushNotificationToken = senderPushNotificationToken
    self.canSaveMedia = canSaveMedia
    self.isChatHistoryStored = isChatHistoryStored
  }
}

// MARK: - Mapping

extension MessengerNetworkRequestDTO {
  /// Преобразует DTO в модель запроса.
  public func mapToModel() -> MessengerNetworkRequestModel {
    MessengerNetworkRequestModel(
      messageText: messageText, 
      messageID: messageID,
      replyMessageText: replyMessageText,
      senderAddress: senderAddress,
      senderLocalMeshAddress: senderLocalMeshAddress,
      senderPublicKey: senderPublicKey,
      senderToxPublicKey: senderToxPublicKey,
      senderPushNotificationToken: senderPushNotificationToken,
      canSaveMedia: canSaveMedia,
      isChatHistoryStored: isChatHistoryStored
    )
  }
}

// MARK: - IdentifiableAndCodable

extension MessengerNetworkRequestDTO: IdentifiableAndCodable {}
