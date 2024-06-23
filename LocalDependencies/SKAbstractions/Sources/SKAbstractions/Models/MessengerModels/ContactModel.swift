//
//  ContactModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 05.06.2024.
//

import SwiftUI

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
  
  /// Список сообщений с этим контактом.
  public var messenges: [MessengeModel]
  
  /// Статус онлайн контакта.
  public var status: ContactModel.Status
  
  /// Публичный ключ для шифрования сообщений.
  public var encryptionPublicKey: String?
  
  /// Публичный ключ для шифрования сообщений.
  public var toxPublicKey: String?
  
  /// Доступны новые сообщения
  public var isNewMessagesAvailable: Bool
  
  /// Пользователь печатает в данный момент
  public var isTyping: Bool
  
  /// Инициализатор для создания нового контакта.
  /// - Parameters:
  ///   - name: Имя контакта.
  ///   - toxAddress: Адрес контакта в сети Tox.
  ///   - meshAddress: Локальный адрес в mesh-сети.
  ///   - messenges: Список сообщений с этим контактом.
  ///   - status: Статус онлайн контакта.
  ///   - encryptionPublicKey: Публичный ключ для шифрования сообщений.
  ///   - toxPublicKey: Публичный ключ для шифрования сообщений.
  ///   - isNewMessagesAvailable: Доступны новые сообщения
  ///   - isTyping: Пользователь печатает в данный момент
  public init(
    name: String?,
    toxAddress: String?,
    meshAddress: String?,
    messenges: [MessengeModel],
    status: ContactModel.Status,
    encryptionPublicKey: String?,
    toxPublicKey: String?,
    isNewMessagesAvailable: Bool,
    isTyping: Bool
  ) {
    self.id = UUID().uuidString
    self.name = name
    self.toxAddress = toxAddress
    self.meshAddress = meshAddress
    self.messenges = messenges
    self.status = status
    self.encryptionPublicKey = encryptionPublicKey
    self.toxPublicKey = toxPublicKey
    self.isNewMessagesAvailable = isNewMessagesAvailable
    self.isTyping = isTyping
  }
}

// MARK: - Mock

extension ContactModel {
  public static func mock() -> Self {
    Self(
      name: nil,
      toxAddress: nil,
      meshAddress: nil,
      messenges: [],
      status: .offline,
      encryptionPublicKey: nil, 
      toxPublicKey: nil, 
      isNewMessagesAvailable: false,
      isTyping: false
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
        "В сети"
      case .offline:
        "Не в сети"
      case .requestChat:
        "Запрос на переписку"
      case .initialChat:
        "Отправили запрос"
      }
    }
  }
}

// MARK: - IdentifiableAndCodable

extension ContactModel: IdentifiableAndCodable {}
extension ContactModel.Status: IdentifiableAndCodable {}
