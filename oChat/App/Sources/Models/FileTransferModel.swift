//
//  FileTransferModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 14.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

/// Модель файла в процессе отправки/приёма
struct FileTransferModel: Identifiable, Codable, Equatable {
  let id: UUID
  let friendID: UInt32
  let fileID: UInt32
  let fileName: String
  let fileSize: UInt64
  var progress: Double
  var status: TransferStatus
  let fileData: Data

  init(
    friendID: UInt32,
    fileID: UInt32,
    fileName: String,
    fileSize: UInt64,
    progress: Double,
    status: TransferStatus,
    fileData: Data
  ) {
    self.id = UUID()
    self.friendID = friendID
    self.fileID = fileID
    self.fileName = fileName
    self.fileSize = fileSize
    self.progress = progress
    self.status = status
    self.fileData = fileData
  }
}

enum TransferStatus: Codable, Equatable {
  case incoming, inProgress, paused, cancelled, completed
}
