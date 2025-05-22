//
//  ToxManager.swift
//  oChat
//
//  Created by Vitalii Sosin on 22.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import ToxSwift

@MainActor
final class ToxManager: ObservableObject {
  static let shared = ToxManager()

  // Подменеджеры
  let friendManager: FriendManager
  let chatManager: ChatManager
  let fileTransferManager: FileTransferManager
  let callManager: CallManager
  let conferenceManager: ConferenceManager
  let connectionManager: ConnectionManager
  let persistenceManager: PersistenceManager

  // Core
  let toxService: ToxServiceProtocol
  private var tasks = Set<Task<Void, Never>>()

  private init() {
    do {
      let bootstrapNodes = try JSONLoader.load([ToxNode].self, fromFile: "bootstrapNodes")
      var toxServiceOptions = ToxServiceOptions()

      // NEW: восстановление, если есть сохранённые данные
      if let data = Data(base64Encoded: UserDefaults.standard.string(forKey: "toxSavedata") ?? ""), !data.isEmpty {
        // TODO: - На время отключу сохранение
        //        toxServiceOptions.savedataType = .toxSave
        //        toxServiceOptions.savedata = data
        //        print("🔄 Восстанавливаем Tox-сессию (\(saved.count) B)")
      }

      let toxService = try ToxService(
        options: toxServiceOptions,
        bootstrapNodes: bootstrapNodes
      )
      self.toxService = toxService

      // Создание менеджеров
      connectionManager = ConnectionManager()
      friendManager = FriendManager(
        toxService: toxService,
        ownAddressProvider: {
          await toxService.getOwnAddress()
        },
        pushTokenProvider: {
          Secrets.pushNotificationToken ?? ""
        })
      fileTransferManager = FileTransferManager(
        toxService: toxService,
        friendManager: friendManager,
        ownAddressProvider: {
          await toxService.getOwnAddress()
        },
        pushTokenProvider: {
          Secrets.pushNotificationToken ?? ""
        })
      chatManager = ChatManager(
        toxService: toxService,
        friendManager: friendManager,
        fileTransferManager: fileTransferManager,
        ownAddressProvider: {
          await toxService.getOwnAddress()
        },
        pushTokenProvider: {
          Secrets.pushNotificationToken ?? ""
        })
      callManager = CallManager(
        toxService: toxService
      )
      conferenceManager = ConferenceManager(
        toxService: toxService
      )
      persistenceManager = PersistenceManager(
        toxService: toxService
      )

      observeStreams()
    } catch {
      fatalError("Не удалось инициализировать ToxService: \(error)")
    }
  }

  /// Корректно останавливает ядро и отменяет все подписки.
  func shutdown() async {
    connectionManager.connectionState = .offline
    // 3. Отключаемся от сети и освобождаем ресурсы toxcore
    await toxService.shutdown()
    print("🚨 Остановка Tox-ядра")
  }

  /// Полный рестарт ядра с сохранением профиля.
  func restart() async throws {
    connectionManager.connectionState = .inProgress
    do {
      // 3. Перезапускаем ядро внутри ToxService
      try await toxService.restart()
      print("🔄 Tox-ядро успешно перезапущено")
    } catch {
      print("❌ Ошибка рестарта ToxService: \(error)")
      throw error
    }
  }

  // Подписка на Асинхронные потоки ToxService
  private func observeStreams() {
    tasks.insert(Task { for await friend in await toxService.friendEvents { await friendManager.handleFriendEvent(friend) } })
    tasks.insert(Task { for await msg in await toxService.incomingMessages { await chatManager.handleIncomingMessage(msg) } })
    tasks.insert(Task { for await file in await toxService.fileEvents { fileTransferManager.handleFileEvent(file) } })
    tasks.insert(Task { for await call in await toxService.callEvents { callManager.handleCallEvent(call) } })
    tasks.insert(Task { for await conf in await toxService.conferenceEvents { conferenceManager.handleConferenceEvent(conf) } })
    tasks.insert(Task { for await state in await toxService.connectionStatusEvents { connectionManager.handle(state) } })
  }
}

// MARK: - Preview

extension ToxManager {
  /// Заглушка с демо-данными, чтобы превью работало офлайн
  static var preview: ToxManager {
    let manager = ToxManager.shared
    return manager
  }
}
