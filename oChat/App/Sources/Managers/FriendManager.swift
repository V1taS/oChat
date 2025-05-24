//
//  FriendManager.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Combine
import SwiftUI
import ToxSwift

/// Менеджер работы с друзьями и запросами дружбы.
final class FriendManager: ObservableObject {
  // Published‑свойства, за которыми будет следить UI
  @Published var spamFriendPublicKeys: Set<Data> = []
  @Published var friendRequests: [FriendRequest] = []
  @Published var pendingAcceptFriendRequests: [FriendRequest] = []
  @Published var friends: [FriendModel] = []

  // Зависимости
  private let toxService: ToxServiceProtocol
  private let cryptoService: CryptoService
  private let ownAddressProvider: () async -> String
  private let pushTokenProvider: () -> String

  init(
    toxService: ToxServiceProtocol,
    cryptoService: CryptoService = .shared,
    ownAddressProvider: @escaping () async -> String,
    pushTokenProvider: @escaping () -> String
  ) {
    self.toxService = toxService
    self.cryptoService = cryptoService
    self.ownAddressProvider = ownAddressProvider
    self.pushTokenProvider = pushTokenProvider
  }

  // MARK: SwiftUI‑Binding helpers

  func bindingForFriend(_ model: FriendModel) -> Binding<FriendModel>? {
    guard let idx = friends.firstIndex(of: model) else { return nil }
    return Binding(get: { self.friends[idx] }, set: { self.friends[idx] = $0 })
  }

  func bindingForFriendRequest(_ model: FriendRequest) -> Binding<FriendRequest>? {
    guard let idx = friendRequests.firstIndex(of: model) else { return nil }
    return Binding(get: { self.friendRequests[idx] }, set: { self.friendRequests[idx] = $0 })
  }

  // MARK: Public API

  /// Добавить друга по 76‑символьному Tox‑адресу.
  func addFriend(addressHex: String, greeting: String) async {
    let requestModel = MessengerNetworkRequestModel(
      payloads: [.message(id: UUID().uuidString, text: greeting)],
      system: .init(meshAddress: nil,
                    toxAddress: nil,
                    publicKeyForEncryption: cryptoService.publicKey(),
                    pushNotificationToken: nil,
                    chatRules: .init())
    )
    guard let greetingJSON = requestModel.toJSONString() else { return }

    let cleaned = addressHex.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").lowercased()
    guard let addressData = Data(hexString: cleaned) else {
      print("❌ Неверный адрес Tox")
      return
    }

    do {
      let friendID = try await toxService.addFriend(withAddress: addressData, greeting: greetingJSON)
      print("✅ friendID = \(friendID)")

      friends.append(
        FriendModel(
          id: friendID,
          address: addressHex,
          meshAddress: nil,
          encryptionPublicKey: nil,
          pushNotificationToken: nil,
          avatar: .init(),
          connectionState: .inProgress,
          isTyping: false,
          unreadCount: 0,
          chatRules: .init()
        )
      )

      ToxManager.shared.chatManager.append(
        message: ChatMessage(
          messageId: nil,
          friendID: friendID,
          message: "Отправлен запрос на добавление в друзья",
          replyMessageText: nil,
          reactions: nil,
          messageType: .system,
          date: Date(),
          messageStatus: .sent,
          attachments: []
        ),
        to: friendID
      )

      ToxManager.shared.chatManager.append(
        message: .init(
          messageId: nil,
          friendID: friendID,
          message: greeting,
          replyMessageText: nil,
          reactions: nil,
          messageType: .outgoing,
          date: Date(),
          messageStatus: .sent,
          attachments: []
        ),
        to: friendID
      )
    } catch {
      print("❌ addFriend error: \(error)")
    }
  }

  /// Принять входящий запрос дружбы.
  func acceptFriendRequest(_ request: FriendRequest) async {
    do {
      let friendID = try await toxService.acceptFriendRequest(publicKey: request.publicKey)
      friendRequests.removeAll { $0.fullAddress == request.fullAddress }

      var friendRequest = request
      friendRequest.friendID = friendID
      pendingAcceptFriendRequests.append(friendRequest)

      friends.append(
        FriendModel(
          id: friendID,
          address: request.publicKey.hex,
          meshAddress: nil,
          encryptionPublicKey: request.publicKeyForEncryption,
          pushNotificationToken: nil,
          avatar: .init(),
          connectionState: .inProgress,
          isTyping: false,
          unreadCount: 0,
          chatRules: request.chatRules
        )
      )

      if let text = request.message {
        await ToxManager.shared.chatManager.append(
          message: ChatMessage(
            messageId: nil,
            friendID: friendID,
            message: text,
            replyMessageText: nil,
            reactions: nil,
            messageType: .incoming,
            date: Date(),
            messageStatus: .sent,
            attachments: []
          ),
          to: friendID
        )
      }
    } catch {
      print("❌ acceptFriendRequest error: \(error)")
    }
  }

  func firtMessageAfterAcceptFriend(friendID: UInt32) async {
    if let idx = pendingAcceptFriendRequests.firstIndex(where: { $0.friendID == friendID }),
       let publicKeyForEncryption = pendingAcceptFriendRequests[idx].publicKeyForEncryption {
      let pushNotificationTokenEncrypt = cryptoService.encrypt(pushTokenProvider(), publicKey: publicKeyForEncryption)
      let toxAddressEncrypt = await cryptoService.encrypt(ownAddressProvider(), publicKey: publicKeyForEncryption)
      let messageTextEncrypt = cryptoService.encrypt("Друг успешно подтвердил Вашу дружбу", publicKey: publicKeyForEncryption) ?? ""

      let model = MessengerNetworkRequestModel(
        payloads: [
          .system(
            id: UUID().uuidString,
            text: messageTextEncrypt
          )
        ],
        system: .init(
          meshAddress: nil,
          toxAddress: toxAddressEncrypt,
          publicKeyForEncryption: cryptoService.publicKey(),
          pushNotificationToken: pushNotificationTokenEncrypt,
          chatRules: .init()
        )
      )

      guard let json = model.toJSONString() else { return }

      do {
        let messageId = try await toxService.sendMessage(
          toFriend: friendID,
          text: json
        )
        // Сохраним и в локальный массив (как исходящее)
        let outgoing = ChatMessage(
          messageId: messageId,
          friendID: friendID,
          message: "вы успешно добавили друга",
          replyMessageText: nil,
          reactions: nil,
          messageType: .system,
          date: Date(),
          messageStatus: .sent,
          attachments: nil
        )
        await ToxManager.shared.chatManager.append(message: outgoing, to: friendID)
        pendingAcceptFriendRequests.remove(at: idx)
      } catch {
        print("Ошибка отправки сообщения другу \(friendID): \(error)")
      }
    }
  }

  func rejectFriendRequest(_ request: FriendRequest) async {
    if let friendsIndex = friendRequests.firstIndex(where: { $0.fullAddress == request.fullAddress }) {
      friendRequests.remove(at: friendsIndex)
    }
  }

  func addToSpamList(_ publicKey: Data) async {
    if let friendsIndex = friendRequests.firstIndex(where: { $0.fullAddress == publicKey.hex }) {
      friendRequests.remove(at: friendsIndex)
    }
    
    spamFriendPublicKeys.insert(publicKey)
  }

  func handleFriendEvent(_ event: FriendEvent) async {
    switch event {
    case let .request(publicKey, message):
      guard !spamFriendPublicKeys.contains(publicKey) else { return }
      guard
        let data = message.data(using: .utf8),
        let model = try? JSONDecoder().decode(MessengerNetworkRequestModel.self, from: data),
        case let .message(_, text) = model.payloads.first
      else { return }

      friendRequests.append(
        FriendRequest(
          message: text,
          publicKey: publicKey,
          meshAddress: nil,
          toxAddress: nil,
          publicKeyForEncryption: model.system.publicKeyForEncryption,
          pushNotificationToken: nil,
          chatRules: model.system.chatRules
        )
      )

    case let .connectionStatusChanged(friendID, state):
      let connectionState: ConnectionStatus = state == .none ? .offline : .online

      if let idx = friends.firstIndex(where: { $0.id == friendID }) {
        friends[idx].connectionState = connectionState
      }

      if connectionState == .online {
        await firtMessageAfterAcceptFriend(friendID: friendID)
      }
    case let .typing(friendID, isTyping):
      if let idx = friends.firstIndex(where: { $0.id == friendID }) {
        friends[idx].isTyping = isTyping
      }
    default:
      break
    }
  }
}

// MARK: - Preview

extension FriendManager {
  /// Заглушка с демо-данными, чтобы превью работало офлайн
  static var preview: FriendManager {
    let toxService = try! ToxService()
    let friendManager = FriendManager(
      toxService: toxService,
      ownAddressProvider: {
        await toxService.getOwnAddress()
      },
      pushTokenProvider: {
        Secrets.pushNotificationToken ?? ""
      })
    friendManager.friendRequests = FriendRequest.mockList()
    friendManager.friends = FriendModel.mockList()
    return friendManager
  }
}
