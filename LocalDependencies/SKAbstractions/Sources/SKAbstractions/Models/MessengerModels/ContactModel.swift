//
//  ContactModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 05.06.2024.
//

import SwiftUI

public typealias ContactModels = [String: ContactModel]

/// Структура для описания контакта в мессенджере.
public struct ContactModel {
  
  /// Уникальный идентификатор контакта.
  public var id: String
  
  /// Имя контакта, может быть nil, если имя не задано.
  public var name: String?
  
  /// Адрес контакта в сети Tor.
  public var toxAddress: String?
  
  /// Локальный адрес в mesh-сети.
  public var meshAddress: String?
  
  /// Статус онлайн контакта.
  public var status: ContactModel.Status
  
  /// Публичный ключ для шифрования сообщений.
  public var encryptionPublicKey: String?
  
  /// Публичный ключ для шифрования сообщений.
  public var toxPublicKey: String?
  
  /// Токен для отправки пушей
  public var pushNotificationToken: String?
  
  /// Доступны новые сообщения
  public var isNewMessagesAvailable: Bool
  
  /// Пользователь печатает в данный момент
  public var isTyping: Bool
  
  /// Разрешить собеседнику сохранять отправленные вами фото и видео
  public var canSaveMedia: Bool
  
  /// Разрешить собеседнику хранить историю переписки
  public var isChatHistoryStored: Bool
  
  /// Дата создания контакта
  public let dateOfCreation: Date
  
  /// Инициализатор для создания нового контакта.
  /// - Parameters:
  ///   - name: Имя контакта.
  ///   - toxAddress: Адрес контакта в сети Tox.
  ///   - meshAddress: Локальный адрес в mesh-сети.
  ///   - status: Статус онлайн контакта.
  ///   - encryptionPublicKey: Публичный ключ для шифрования сообщений.
  ///   - toxPublicKey: Публичный ключ для шифрования сообщений.
  ///   - pushNotificationToken: Токен для отправки пушей
  ///   - isNewMessagesAvailable: Доступны новые сообщения
  ///   - isTyping: Пользователь печатает в данный момент
  ///   - canSaveMedia: Разрешить собеседнику сохранять отправленные вами фото и видео
  ///   - isChatHistoryStored: Разрешить собеседнику хранить историю переписки
  public init(
    id: String = UUID().uuidString,
    name: String?,
    toxAddress: String?,
    meshAddress: String?,
    status: ContactModel.Status,
    encryptionPublicKey: String?,
    toxPublicKey: String?,
    pushNotificationToken: String?,
    isNewMessagesAvailable: Bool,
    isTyping: Bool,
    canSaveMedia: Bool,
    isChatHistoryStored: Bool
  ) {
    self.id = id
    self.name = name
    self.toxAddress = toxAddress
    self.meshAddress = meshAddress
    self.status = status
    self.encryptionPublicKey = encryptionPublicKey
    self.toxPublicKey = toxPublicKey
    self.pushNotificationToken = pushNotificationToken
    self.isNewMessagesAvailable = isNewMessagesAvailable
    self.isTyping = isTyping
    self.canSaveMedia = canSaveMedia
    self.isChatHistoryStored = isChatHistoryStored
    self.dateOfCreation = Date()
  }
}

// MARK: - Mock

extension ContactModel {
  public static func mock() -> Self {
    Self(
      name: nil,
      toxAddress: nil,
      meshAddress: nil,
      status: .offline,
      encryptionPublicKey: nil, 
      toxPublicKey: nil, 
      pushNotificationToken: nil,
      isNewMessagesAvailable: false,
      isTyping: false,
      canSaveMedia: false,
      isChatHistoryStored: false
    )
  }
}

// MARK: - Status

extension ContactModel {
  /// Перечисление, представляющее статусы.
  public enum Status: String {
    /// Пользователь в сети.
    case online
    
    /// Пользователь не в сети.
    case offline
    
    /// Неизвестный контакт запросил переписку с тобой
    case requestChat
    
    /// Ты запросил переписку с контактом
    case initialChat
    
    /// Заголовок
    public var title: String {
      switch self {
      case .online:
        AbstractionsStrings.SKAbstractionsLocalization.commonStatusTitleOnline
      case .offline:
        AbstractionsStrings.SKAbstractionsLocalization.commonStatusTitleOffline
      case .requestChat:
        AbstractionsStrings.SKAbstractionsLocalization.contactModelStatusTitleConversationRequest
      case .initialChat:
        AbstractionsStrings.SKAbstractionsLocalization.contactModelStatusTitleSentRequest
      }
    }
  }
}

// MARK: - IdentifiableAndCodable

extension ContactModel: IdentifiableAndCodable {}
extension ContactModel.Status: IdentifiableAndCodable {}
