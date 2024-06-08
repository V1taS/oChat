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
  public var onionAddress: String?
  
  /// Локальный адрес в mesh-сети.
  public var meshAddress: String?
  
  /// Список сообщений с этим контактом.
  public var messenges: [MessengeModel]
  
  /// Статус онлайн контакта.
  public var status: ContactModel.Status
  
  /// Публичный ключ для шифрования сообщений.
  public var encryptionPublicKey: String?
  
  /// Индикатор защиты диалога с этим контактом паролем.
  public var isPasswordDialogProtected: Bool
  
  /// Инициализатор для создания нового контакта.
  /// - Parameters:
  ///   - name: Имя контакта.
  ///   - onionAddress: Адрес контакта в сети Tor.
  ///   - meshAddress: Локальный адрес в mesh-сети.
  ///   - messenges: Список сообщений с этим контактом.
  ///   - status: Статус онлайн контакта.
  ///   - encryptionPublicKey: Публичный ключ для шифрования сообщений.
  ///   - isPasswordDialogProtected: Индикатор защиты диалога паролем.
  public init(
    name: String?,
    onionAddress: String?,
    meshAddress: String?,
    messenges: [MessengeModel],
    status: ContactModel.Status,
    encryptionPublicKey: String?,
    isPasswordDialogProtected: Bool
  ) {
    self.id = UUID().uuidString
    self.name = name
    self.onionAddress = onionAddress
    self.meshAddress = meshAddress
    self.messenges = messenges
    self.status = status
    self.encryptionPublicKey = encryptionPublicKey
    self.isPasswordDialogProtected = isPasswordDialogProtected
  }
}

// MARK: - Mock

extension ContactModel {
  public static func mock() -> Self {
    Self(
      name: nil,
      onionAddress: nil,
      meshAddress: nil,
      messenges: [],
      status: .inProgress,
      encryptionPublicKey: nil,
      isPasswordDialogProtected: false
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
    
    /// Переписка в процессе.
    case inProgress
    
    /// Запрос на начало переписки.
    case requested
    
    /// Заголовок
    public var title: String {
      switch self {
      case .online:
        "В сети"
      case .offline:
        "Не в сети"
      case .inProgress:
        "Подключение..."
      case .requested:
        "Инвайт"
      }
    }
  }
}

// MARK: - IdentifiableAndCodable

extension ContactModel: IdentifiableAndCodable {}
extension ContactModel.Status: IdentifiableAndCodable {}
