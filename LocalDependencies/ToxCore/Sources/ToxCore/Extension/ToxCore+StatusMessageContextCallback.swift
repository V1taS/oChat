//
//  ToxCore+StatusMessageContextCallback.swift
//  ToxCore
//
//  Created by Vitalii Sosin on 16.06.2024.
//

import Foundation
import ToxCoreCpp

final class StatusMessageContext {
  var callback: (Int32, String) -> Void
  
  init(callback: @escaping (Int32, String) -> Void) {
    self.callback = callback
  }
}

var globalStatusMessageContext: StatusMessageContext?

let friendStatusMessageCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?,
  UInt32,
  UnsafePointer<UInt8>?,
  size_t,
  UnsafeMutableRawPointer?
) -> Void = { tox, friendNumber, messagePtr, length, userData in
  // Проверяем, что указатель на сообщение не равен nil и длина сообщения больше нуля
  guard let messagePtr = messagePtr, length > 0 else { return }
  
  // Получаем контекст из пользовательских данных
  guard let context = globalStatusMessageContext else {
    print("🔴 Ошибка: контекст не установлен")
    return
  }
  
  // Создаем Data из указателя на байты сообщения
  let messageData = Data(bytes: messagePtr, count: Int(length))
  
  // Преобразуем Data в строку и вызываем замыкание с идентификатором друга и текстом сообщения
  if let messageStr = String(data: messageData, encoding: .utf8) {
    context.callback(Int32(friendNumber), messageStr)
  }
}
