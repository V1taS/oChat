//
//  ToxCore+FileCallback.swift
//  ToxCore
//
//  Created by Vitalii Sosin on 05.07.2024.
//

import Foundation
import ToxCoreCpp

final class FileControlCallbackContext {
  var callback: (Int32, Int32, TOX_FILE_CONTROL) -> Void
  
  init(callback: @escaping (Int32, Int32, TOX_FILE_CONTROL) -> Void) {
    self.callback = callback
  }
}

final class FileChunkRequestCallbackContext {
  var callback: (Int32, Int32, UInt64, Int) -> Void
  
  init(callback: @escaping (Int32, Int32, UInt64, Int) -> Void) {
    self.callback = callback
  }
}

final class FileRecvCallbackContext {
  var callback: (Int32, Int32, UInt32, UInt64, Data) -> Void
  
  init(callback: @escaping (Int32, Int32, UInt32, UInt64, Data) -> Void) {
    self.callback = callback
  }
}

var globalFileControlCallbackContext: FileControlCallbackContext?
var globalFileChunkRequestCallbackContext: FileChunkRequestCallbackContext?

let fileControlCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?,
  Tox_Friend_Number,
  Tox_File_Number,
  Tox_File_Control,
  UnsafeMutableRawPointer?
) -> Void = { tox, friendNumber, fileNumber, control, userData in
  guard let context = globalFileControlCallbackContext else {
    print("🔴 Ошибка: контекст управления файлами не установлен")
    return
  }
  
  context.callback(Int32(friendNumber), Int32(fileNumber), control)
}

let fileChunkRequestCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?,
  Tox_Friend_Number,
  Tox_File_Number,
  UInt64,
  size_t,
  UnsafeMutableRawPointer?
) -> Void = { tox, friendNumber, fileNumber, position, length, userData in
  guard let context = globalFileChunkRequestCallbackContext else {
    print("🔴 Ошибка: контекст запроса чанков файлов не установлен")
    return
  }
  
  context.callback(Int32(friendNumber), Int32(fileNumber), position, Int(length))
}
