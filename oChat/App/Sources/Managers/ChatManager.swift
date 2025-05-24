//
//  ChatManager.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Combine
import SwiftUI
import ToxSwift

/// Менеджер личных сообщений.
final class ChatManager: ObservableObject {
  @Published var messages: [UInt32: [ChatMessage]] = [:]

  private let toxService: ToxServiceProtocol
  private let cryptoService: CryptoService
  private unowned let friendManager: FriendManager
  private unowned let fileTransferManager: FileTransferManager
  private let ownAddressProvider: () async -> String
  private let pushTokenProvider: () -> String

  init(
    toxService: ToxServiceProtocol,
    cryptoService: CryptoService = .shared,
    friendManager: FriendManager,
    fileTransferManager: FileTransferManager,
    ownAddressProvider: @escaping () async -> String,
    pushTokenProvider: @escaping () -> String
  ) {
    self.toxService = toxService
    self.cryptoService = cryptoService
    self.friendManager = friendManager
    self.fileTransferManager = fileTransferManager
    self.ownAddressProvider = ownAddressProvider
    self.pushTokenProvider = pushTokenProvider
  }

  func bindingForMessages(friendId: UInt32) -> Binding<[ChatMessage]> {
    Binding(get: { self.messages[friendId, default: []] }, set: { self.messages[friendId] = $0 })
  }

  // Приём входящих сообщений
  func handleIncomingMessage(_ incoming: IncomingMessage) async {
    guard
      let data = incoming.text.data(using: .utf8),
      let model = try? JSONDecoder().decode(MessengerNetworkRequestModel.self, from: data)
    else { return }

    let toxAddressDecrypt = cryptoService.decrypt(model.system.toxAddress)
    guard let idx = friendManager.friends.firstIndex(where: { $0.id == incoming.friendID }) else { return }
    let pushNotificationTokenDecrypt = cryptoService.decrypt(model.system.pushNotificationToken)
    friendManager.friends[idx].pushNotificationToken = pushNotificationTokenDecrypt
    friendManager.friends[idx].address = toxAddressDecrypt
    friendManager.friends[idx].encryptionPublicKey = model.system.publicKeyForEncryption

    for payload in model.payloads {
      switch payload {
      case let .message(_, encryptedText):
        guard let text = cryptoService.decrypt(encryptedText) else { continue }
        append(message: ChatMessage(
          messageId: nil,
          friendID: incoming.friendID,
          message: text,
          replyMessageText: nil,
          reactions: nil,
          messageType: .incoming,
          date: Date(),
          messageStatus: .sent,
          attachments: []
        ), to: incoming.friendID)
      case let .system(_, encryptedText):
        guard let text = cryptoService.decrypt(encryptedText) else { continue }
        append(message: ChatMessage(
          messageId: nil,
          friendID: incoming.friendID,
          message: text,
          replyMessageText: nil,
          reactions: nil,
          messageType: .system,
          date: Date(),
          messageStatus: .sent,
          attachments: []
        ), to: incoming.friendID)
      default:
        break
      }
    }
  }

  // Отправка
  func sendMessage(to friendID: UInt32, text: String) async {
    let local = ChatMessage(
      messageId: nil,
      friendID: friendID,
      message: text,
      replyMessageText: nil,
      reactions: nil,
      messageType: .outgoing,
      date: Date(),
      messageStatus: .sent,
      attachments: nil
    )
    append(message: local, to: friendID)

    guard let friend = friendManager.friends.first(where: { $0.id == friendID }),
          let pk = friend.encryptionPublicKey else { return }

    let encText = cryptoService.encrypt(text, publicKey: pk) ?? ""
    let pushEnc = cryptoService.encrypt(pushTokenProvider(), publicKey: pk)
    let addrEnc = cryptoService.encrypt(await ownAddressProvider(), publicKey: pk)

    let model = MessengerNetworkRequestModel(
      payloads: [.message(id: UUID().uuidString, text: encText)],
      system: .init(meshAddress: nil,
                    toxAddress: addrEnc,
                    publicKeyForEncryption: cryptoService.publicKey(),
                    pushNotificationToken: pushEnc,
                    chatRules: friend.chatRules)
    )
    guard let json = model.toJSONString() else { return }

    do {
      let messageID = try await toxService.sendMessage(toFriend: friendID, text: json)
      markSent(friendID: friendID, localID: local.id, remoteID: messageID)
    } catch {
      print("sendMessage error: \(error)")
    }
  }

  // Модификаторы
  func append(message: ChatMessage, to friendID: UInt32) {
    messages[friendID, default: []].append(message)
  }

  func removeChat(for friendID: UInt32) {
    messages.removeValue(forKey: friendID)
  }

  func markSent(friendID: UInt32, localID: UUID?, remoteID: UInt32?) {
    guard let localID, let remoteID, let idx = messages[friendID]?.firstIndex(where: { $0.id == localID }) else { return }
    messages[friendID]?[idx].messageId = remoteID
  }

  func markRead(friendID: UInt32, messageID: UInt32) {
    guard let idx = messages[friendID]?.firstIndex(where: { $0.messageId == messageID }) else { return }
    messages[friendID]?[idx].messageStatus = .read
  }
}

// MARK: - Preview

extension ChatManager {
  /// Заглушка с демо-данными, чтобы превью работало офлайн
  static var preview: ChatManager {
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

    let fileTransferManager = FileTransferManager(
      toxService: toxService,
      friendManager: friendManager,
      ownAddressProvider: {
        await toxService.getOwnAddress()
      },
      pushTokenProvider: {
        Secrets.pushNotificationToken ?? ""
      })

    let chatManager = ChatManager(
      toxService: toxService,
      friendManager: friendManager,
      fileTransferManager: fileTransferManager,
      ownAddressProvider: {
        await toxService.getOwnAddress()
      },
      pushTokenProvider: {
        Secrets.pushNotificationToken ?? ""
      })
    chatManager.messages = [
      0: ChatMessage.mockList(friendID: 0),
      1: ChatMessage.mockList(friendID: 1),
      2: ChatMessage.mockList(friendID: 2),
    ]
    friendManager.friendRequests = FriendRequest.mockList()
    friendManager.friends = FriendModel.mockList()
    return chatManager
  }
}
