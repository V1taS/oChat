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
  
  /// Инициализирует новый экземпляр сетевого запроса для мессенджера с заданными параметрами.
  /// - Parameters:
  ///   - messageText: Текст сообщения.
  ///   - senderAddress: Адрес в сети для отправки.
  ///   - senderLocalMeshAddress: Адрес в локальной сети для отправки.
  ///   - senderPublicKey: Публичный ключ отправителя.
  ///   - senderToxPublicKey: Публичный ключ для шифрования сообщений.
  ///   - senderPushNotificationToken: Токен для отправки пушей
  public init(
    messageText: String?,
    senderAddress: String,
    senderLocalMeshAddress: String?,
    senderPublicKey: String?,
    senderToxPublicKey: String?,
    senderPushNotificationToken: String?
  ) {
    self.messageText = messageText
    self.senderAddress = senderAddress
    self.senderLocalMeshAddress = senderLocalMeshAddress
    self.senderPublicKey = senderPublicKey
    self.senderToxPublicKey = senderToxPublicKey
    self.senderPushNotificationToken = senderPushNotificationToken
  }
}

// MARK: - Mapping

extension MessengerNetworkRequestDTO {
  /// Преобразует DTO в модель запроса.
  public func mapToModel() -> MessengerNetworkRequestModel {
    MessengerNetworkRequestModel(
      messageText: messageText,
      senderAddress: senderAddress,
      senderLocalMeshAddress: senderLocalMeshAddress,
      senderPublicKey: senderPublicKey,
      senderToxPublicKey: senderToxPublicKey, 
      senderPushNotificationToken: senderPushNotificationToken
    )
  }
}

// MARK: - IdentifiableAndCodable

extension MessengerNetworkRequestDTO: IdentifiableAndCodable {}
