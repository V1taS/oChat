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
  
  /// Адрес получателя в сети Tor для доставки сообщения.
  public let recipientTorAddress: String
  
  /// Адрес получателя в локальной mesh-сети для отправки сообщений при отсутствии интернета.
  public let recipientLocalMeshAddress: String
  
  /// Публичный ключ отправителя для верификации его подлинности получателем.
  public let senderPublicKey: String
  
  /// Строковое представление статуса контакта отправителя.
  public var senderContactStatus: String
  
  /// Инициализирует новый экземпляр сетевого запроса для мессенджера с заданными параметрами.
  /// - Parameters:
  ///   - messageText: Текст сообщения.
  ///   - recipientTorAddress: Адрес в сети Tor для отправки.
  ///   - recipientLocalMeshAddress: Адрес в локальной сети для отправки.
  ///   - senderPublicKey: Публичный ключ отправителя.
  ///   - senderContactStatus: Строковое представление статуса отправителя.
  public init(
    messageText: String?,
    recipientTorAddress: String,
    recipientLocalMeshAddress: String,
    senderPublicKey: String,
    senderContactStatus: String
  ) {
    self.messageText = messageText
    self.recipientTorAddress = recipientTorAddress
    self.recipientLocalMeshAddress = recipientLocalMeshAddress
    self.senderPublicKey = senderPublicKey
    self.senderContactStatus = senderContactStatus
  }
}

// MARK: - Mapping

extension MessengerNetworkRequestDTO {
  /// Преобразует DTO в модель запроса.
  public func mapToModel() -> MessengerNetworkRequestModel {
    MessengerNetworkRequestModel(
      messageText: messageText,
      recipientTorAddress: recipientTorAddress,
      recipientLocalMeshAddress: recipientLocalMeshAddress,
      senderPublicKey: senderPublicKey,
      senderContactStatus: ContactModel.Status(rawValue: senderContactStatus) ?? .inProgress
    )
  }
}

// MARK: - IdentifiableAndCodable

extension MessengerNetworkRequestDTO: IdentifiableAndCodable {}
