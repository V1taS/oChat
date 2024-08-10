//
//  ToxCore+LogContextCallback.swift
//  ToxCore
//
//  Created by Vitalii Sosin on 16.06.2024.
//

import Foundation
import ToxCoreCpp

// Класс для хранения контекста логирования и обработки обратных вызовов.
final class LogContext {
  var callback: (String, TOX_LOG_LEVEL, String, UInt32, String, String, UnsafeMutableRawPointer?) -> Void
  
  init(callback: @escaping (String, TOX_LOG_LEVEL, String, UInt32, String, String, UnsafeMutableRawPointer?) -> Void) {
    self.callback = callback
  }
}

// Глобальная переменная для хранения контекста логирования.
var globalLogContext: LogContext?

// Объявляем тип для обратного вызова, соответствующий `Tox_Log_Callback`.
typealias ToxLogCallback = @convention(c) (
  UnsafeMutablePointer<Tox>?,
  TOX_LOG_LEVEL,
  UnsafePointer<CChar>?,
  UInt32,
  UnsafePointer<CChar>?,
  UnsafePointer<CChar>?,
  UnsafeMutableRawPointer?
) -> Void

// Функция обратного вызова для логирования.
let logCallback: ToxLogCallback = { (tox: UnsafeMutablePointer<Tox>?,
                                     level: TOX_LOG_LEVEL,
                                     file: UnsafePointer<CChar>?,
                                     line: UInt32,
                                     funcName: UnsafePointer<CChar>?,
                                     message: UnsafePointer<CChar>?,
                                     userData: UnsafeMutableRawPointer?) in
  guard let context = globalLogContext else {
    assertionFailure("Ошибка: контекст не установлен")
    return
  }
  
  // Преобразуем C-строки в Swift-строки
  let fileStr = file.map { String(cString: $0) } ?? "Unknown file"
  let funcStr = funcName.map { String(cString: $0) } ?? "Unknown function"
  let messageStr = message.map { String(cString: $0) } ?? "Unknown message"
  let userDataStr = userData != nil ? "Data available" : "No user data"
  
  // Вызываем переданное замыкание с аргументами
  context.callback(fileStr, level, funcStr, line, messageStr, userDataStr, userData)
}
