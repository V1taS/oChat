//
//  FriendModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 14.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

/// Модель друга, чтобы удобно хранить в списке (для SwiftUI)
struct FriendModel: Identifiable, Equatable {
  /// FriendID
  let id: UInt32

  /// Tox 76-символьный адрес друга
  var address: String?

  /// Локальный адрес в mesh-сети.
  var meshAddress: String?

  /// Публичный ключ для шифрования сообщений.
  var encryptionPublicKey: String?

  /// Токен для отправки пушей
  var pushNotificationToken: String?

  /// Аватарка пользователя
  var avatar: AvatarModel = .init()

  /// Статус контакта (В сети или е в сети)
  var connectionState: ConnectionStatus

  /// Печатает в данный момент
  var isTyping: Bool

  /// Непрочитанные сообщения
  var unreadCount: Int

  /// Правила для конкретного чата
  var chatRules: ChatRules

  /// Короткая версия записи адреса
  var shortAddress: String {
    guard let address else { return "" }
    return "\(address.prefix(5))…\(address.suffix(5))"
  }
}

#if DEBUG
import Foundation

extension FriendModel {
  /// Моковые данные для предпросмотра и юнит-тестов
  static func mockList() -> [FriendModel] {
    [
      FriendModel(
        id: 1,
        address: "9F3C6E0AAF81D4B6C9E3A1B2C3D4E5F6789ABCDEF0123456789ABCDEF012345",
        meshAddress: "10.0.0.42",
        encryptionPublicKey: "8A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E7F8A9B0C1D2E3F4A5B6C7D8E9F0A1",
        pushNotificationToken: "f8837d79de57471e8b5e9d4c3b2a1f0e",
        avatar: .init(),
        connectionState: .online,
        isTyping: false,
        unreadCount: 2,
        chatRules: .init()
      ),
      FriendModel(
        id: 2,
        address: "1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF",
        meshAddress: "10.0.0.73",
        encryptionPublicKey: "0F1E2D3C4B5A69788796959493929190F0E0D0C0B0A09080706050403020100F",
        pushNotificationToken: "a17f5c93bcd94d23bf1e2a3c45d67890",
        avatar: .init(),
        connectionState: .offline,
        isTyping: false,
        unreadCount: 0,
        chatRules: .init()
      ),
      FriendModel(
        id: 3,
        address: "FEDCBA0987654321FEDCBA0987654321FEDCBA0987654321FEDCBA0987654321",
        meshAddress: nil,
        encryptionPublicKey: nil,
        pushNotificationToken: nil,
        avatar: .init(),
        connectionState: .online,
        isTyping: true,
        unreadCount: 5,
        chatRules: .init()
      )
    ]
  }
}
#endif
