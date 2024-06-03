//
//  MessengerDialogModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation

public struct MessengerDialogModel: Equatable, Identifiable {
  /// Уникальные ИДшник
  public var id: String
  /// Имя отправителя
  public let senderName: String
  /// Имя получателя
  public let recipientName: String
  /// Сообщения
  public let messenges: [MessengeModel]
  /// Стоимость отправки сообщение
  public let costOfSendingMessage: String
  /// Скрыть диалог
  public let isHiddenDialog: Bool
  
  public init(
    senderName: String,
    recipientName: String,
    messenges: [MessengerDialogModel.MessengeModel],
    costOfSendingMessage: String,
    isHiddenDialog: Bool
  ) {
    self.id = UUID().uuidString
    self.senderName = senderName
    self.recipientName = recipientName
    self.messenges = messenges
    self.costOfSendingMessage = costOfSendingMessage
    self.isHiddenDialog = isHiddenDialog
  }
}

// MARK: - MessengeModel

extension MessengerDialogModel {
  public struct MessengeModel: Equatable {
    /// Уникальный ИДшник
    let id: String
    /// Тип сообщения
    let messengeType: MessengeType
    /// Сообщение
    let message: String
    /// Дата отправления
    let date: Date?
    
    // MARK: - Init
    
    init(
      messengeType: MessengerDialogModel.MessengeModel.MessengeType,
      message: String,
      date: Date?
    ) {
      self.id = UUID().uuidString
      self.messengeType = messengeType
      self.message = message
      self.date = date
    }
    
    // MARK: - MessengeType
    
    public enum MessengeType: Equatable {
      /// Мною отправленное сообщение
      case own
      /// ПОлученное сообщение
      case received
    }
  }
}
