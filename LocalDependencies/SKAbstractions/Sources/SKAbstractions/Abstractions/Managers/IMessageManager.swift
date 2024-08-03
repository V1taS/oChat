//
//  IMessageManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import Foundation

/// Протокол для управления сообщениями в приложении.
public protocol IMessageManager {
  
  /// Отправляет сообщение.
  /// - Parameters:
  ///   - toxPublicKey: Публичный ключ Tox получателя.
  ///   - messengerRequest: Модель сетевого запроса мессенджера.
  /// - Returns: Идентификатор сообщения или nil, если отправка не удалась.
  func sendMessage(
    toxPublicKey: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32?
  
  /// Отправляет файл.
  /// - Parameters:
  ///   - toxPublicKey: Публичный ключ Tox отправителя.
  ///   - recipientPublicKey: Публичный ключ Tox получателя.
  ///   - recordModel: Модель записи сообщения.
  ///   - messengerRequest: Модель сетевого запроса мессенджера.
  ///   - files: Список файлов для отправки.
  func sendFile(
    toxPublicKey: String,
    recipientPublicKey: String,
    recordModel: MessengeRecordingModel?,
    messengerRequest: MessengerNetworkRequestModel,
    files: [URL]
  ) async
  
  /// Инициализирует чат.
  /// - Parameters:
  ///   - senderAddress: Адрес отправителя.
  ///   - messengerRequest: Модель сетевого запроса мессенджера.
  /// - Returns: Идентификатор чата или nil, если инициализация не удалась.
  func initialChat(
    senderAddress: String,
    messengerRequest: MessengerNetworkRequestModel?
  ) async -> Int32?
}
