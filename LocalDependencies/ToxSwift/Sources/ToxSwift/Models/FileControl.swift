//
//  FileControl.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 7.05.2025.
//

import Foundation
import CTox
import CSodium

// MARK: - Управление файлом

/// Управляющие команды для `tox_file_control`.
public enum FileControl: UInt8 {
  case pause      = 0   // TOX_FILE_CONTROL_PAUSE
  case resume     = 1   // TOX_FILE_CONTROL_RESUME
  case cancel     = 2   // TOX_FILE_CONTROL_CANCEL
  case kill       = 3   // TOX_FILE_CONTROL_KILL

  var cValue: TOX_FILE_CONTROL { TOX_FILE_CONTROL(UInt32(rawValue)) }
}

/// События, отражающие ход обмена файлами.
public enum FileEvent: Sendable {
  /// Входящий запрос на отправку файла.
  case incomingRequest(friendID: UInt32,
                       fileID: UInt32,
                       kind: FileKind,
                       size: UInt64,
                       fileName: String)

  /// Запрос дружественного клиента на следующий чанк.
  case chunkRequest(friendID: UInt32,
                    fileID: UInt32,
                    position: UInt64,
                    length: UInt32)

  /// Получен кусок данных.
  case chunk(friendID: UInt32,
             fileID: UInt32,
             position: UInt64,
             data: Data)

  /// Изменение состояния передачи по `tox_file_control`.
  case stateChanged(friendID: UInt32,
                    fileID: UInt32,
                    control: FileControl)
}
