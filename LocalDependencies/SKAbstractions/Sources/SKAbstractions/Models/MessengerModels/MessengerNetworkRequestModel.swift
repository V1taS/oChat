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
  
  /// Адрес получателя в сети Tor для доставки сообщения.
  public let recipientTorAddress: String
  
  /// Адрес получателя в локальной mesh-сети, используемый для отправки сообщений при отсутствии интернета.
  public let recipientLocalMeshAddress: String
  
  /// Публичный ключ отправителя для верификации его подлинности получателем.
  public let senderPublicKey: String
  
  /// Текущий статус контакта отправителя.
  public var senderContactStatus: ContactModel.Status
  
  /// Инициализирует новый экземпляр сетевого запроса для мессенджера с заданными параметрами.
  /// - Parameters:
  ///   - messageText: Текст сообщения.
  ///   - recipientTorAddress: Адрес в сети Tor для отправки.
  ///   - recipientLocalMeshAddress: Адрес в локальной сети для отправки.
  ///   - senderPublicKey: Публичный ключ отправителя.
  ///   - senderContactStatus: Статус контакта отправителя.
  public init(
    messageText: String?,
    recipientTorAddress: String,
    recipientLocalMeshAddress: String,
    senderPublicKey: String,
    senderContactStatus: ContactModel.Status
  ) {
    self.messageText = messageText
    self.recipientTorAddress = recipientTorAddress
    self.recipientLocalMeshAddress = recipientLocalMeshAddress
    self.senderPublicKey = senderPublicKey
    self.senderContactStatus = senderContactStatus
  }
}

// MARK: - Mapping

extension MessengerNetworkRequestModel {
  /// Преобразует модель запроса в объект передачи данных (DTO).
  public func mapToDTO() -> MessengerNetworkRequestDTO {
    MessengerNetworkRequestDTO(
      messageText: messageText,
      recipientTorAddress: recipientTorAddress,
      recipientLocalMeshAddress: recipientLocalMeshAddress,
      senderPublicKey: senderPublicKey,
      senderContactStatus: senderContactStatus.rawValue
    )
  }
}

// MARK: - IdentifiableAndCodable

extension MessengerNetworkRequestModel: IdentifiableAndCodable {}
