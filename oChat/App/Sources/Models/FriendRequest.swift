//
//  FriendRequest.swift
//  oChat
//
//  Created by Vitalii Sosin on 16.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

/// Входящий запрос «добавь в друзья».
struct FriendRequest: Identifiable, Codable, Equatable {
  /// Публичный ключ отправителя (32 байта для Tox).
  let publicKey: Data

  /// Локальный адрес в mesh-сети.
  let meshAddress: String?

  /// Tox 76-символьный адрес друга
  let toxAddress: String?

  /// Публичный ключ для шифрования сообщений
  let publicKeyForEncryption: String?

  /// Токен для отправки пушей
  let pushNotificationToken: String?

  /// Правила для конкретного чата
  let chatRules: ChatRules

  // MARK: Identifiable

  /// Используем сам ключ как уникальный идентификатор — Data уже Hashable.
  var id: Data { publicKey }
}

#if DEBUG
extension FriendRequest {

  /// Генерирует массив тестовых `FriendRequest`
  /// - Parameter count: Сколько объектов создать (по-умолчанию 3)
  static func mockList(count: Int = 3) -> [FriendRequest] {
    var result: [FriendRequest] = []

    for _ in 0..<count {
      // 32 байта – как в Tox
      let publicKey = Data((0..<32).map { _ in UInt8.random(in: 0...255) })

      result.append(
        FriendRequest(
          publicKey: publicKey,
          meshAddress: Bool.random() ? "10.0.0.\(Int.random(in: 2...254))" : nil,
          toxAddress: randomHex(length: 76),
          publicKeyForEncryption: randomHex(length: 64),
          pushNotificationToken: UUID().uuidString.replacingOccurrences(of: "-", with: ""),
          chatRules: .init()
        )
      )
    }

    return result
  }

  // MARK: - Вспомогательное

  /// Случайная шестнадцатеричная строка указанной длины
  private static func randomHex(length: Int) -> String {
    let hex = "0123456789ABCDEF"
    return String((0..<length).map { _ in hex.randomElement()! })
  }
}
#endif
