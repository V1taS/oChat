//
//  FileTransferManager.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Combine
import SwiftUI
import ToxSwift

/// Менеджер файловых передач.
final class FileTransferManager: ObservableObject {
  @Published var fileTransfers: [FileTransferModel] = []

  private let toxService: ToxServiceProtocol
  private let cryptoService: CryptoService
  private let zipService: ZipArchiveService
  private unowned let friendManager: FriendManager
  private let ownAddressProvider: () async -> String
  private let pushTokenProvider: () -> String

  init(
    toxService: ToxServiceProtocol,
    cryptoService: CryptoService = .shared,
    zipService: ZipArchiveService = .shared,
    friendManager: FriendManager,
    ownAddressProvider: @escaping () async -> String,
    pushTokenProvider: @escaping () -> String
  ) {
    self.toxService = toxService
    self.cryptoService = cryptoService
    self.zipService = zipService
    self.friendManager = friendManager
    self.ownAddressProvider = ownAddressProvider
    self.pushTokenProvider = pushTokenProvider
  }

  func handleFileEvent(_ event: FileEvent) {
    switch event {
    case let .incomingRequest(friendID, fileID, _, size, name):
      fileTransfers.append(
        FileTransferModel(
          friendID: friendID,
          fileID: fileID,
          fileName: name,
          fileSize: size,
          progress: 0,
          status: .incoming,
          fileData: Data()
        )
      )
    case let .chunk(friendID, fileID, _, data):
      if let idx = fileTransfers.firstIndex(where: { $0.friendID == friendID && $0.fileID == fileID }) {
        fileTransfers[idx].progress += Double(data.count)
      }
    case let .stateChanged(friendID, fileID, control):
      if let idx = fileTransfers.firstIndex(where: { $0.friendID == friendID && $0.fileID == fileID }) {
        switch control {
        case .pause: fileTransfers[idx].status = .paused
        case .resume: fileTransfers[idx].status = .inProgress
        case .cancel, .kill: fileTransfers[idx].status = .cancelled
        }
      }
    default:
      break
    }
  }
}

// MARK: - Preview

extension FileTransferManager {
  /// Заглушка с демо-данными, чтобы превью работало офлайн
  static var preview: FileTransferManager {
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
    return fileTransferManager
  }
}
