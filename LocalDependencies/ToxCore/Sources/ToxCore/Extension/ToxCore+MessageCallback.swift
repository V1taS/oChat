//
//  ToxCore+MessageCallback.swift
//
//
//  Created by Vitalii Sosin on 09.06.2024.
//

import Foundation
import ToxCoreCpp

// Тип данных для хранения контекста сообщений
/// Класс для хранения контекста сообщений и обработки обратных вызовов.
/// - `callback`: Замыкание, которое будет вызвано при получении сообщения.
/// - `init(callback:)`: Инициализирует объект с переданным замыканием.
final class MessageContext {
  var callback: (Int32, String) -> Void
  
  /// Инициализирует объект `MessageContext` с заданным замыканием.
  /// - Parameter callback: Замыкание, которое будет вызвано при получении сообщения.
  init(callback: @escaping (Int32, String) -> Void) {
    self.callback = callback
  }
}

// Глобальная переменная для хранения контекста
var globalConnectionMessageContext: MessageContext?

// Глобальная функция обратного вызова для обработки сообщений
/// Глобальная функция для обработки сообщений от друзей в сети Tox.
/// Эта функция регистрируется в Tox как коллбек и вызывается при получении сообщения.
/// - Parameters:
///   - tox: Указатель на текущий объект Tox.
///   - friendNumber: Уникальный идентификатор друга, от которого было получено сообщение.
///   - messageType: Тип сообщения, определяющий, как оно должно быть интерпретировано (например, текстовое сообщение, действие и т.д.).
///   - messagePtr: Указатель на байты сообщения. Если значение nil, сообщение не было получено.
///   - length: Длина сообщения в байтах.
///   - userData: Указатель на пользовательские данные, переданные вместе с коллбеком.
let messageCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?,
  Tox_Friend_Number,
  TOX_MESSAGE_TYPE,
  UnsafePointer<UInt8>?,
  size_t,
  UnsafeMutableRawPointer?
) -> Void = { tox, friendNumber, messageType, messagePtr, length, userData in
  // Проверяем, что указатель на сообщение не равен nil и длина сообщения больше нуля
  guard let messagePtr = messagePtr, length > 0 else { return }
  
  // Получаем контекст из пользовательских данных
  guard let context = globalConnectionMessageContext else {
    assertionFailure("Ошибка: контекст не установлен")
    return
  }
  
  // Создаем Data из указателя на байты сообщения
  let messageData = Data(bytes: messagePtr, count: Int(length))
  
  // Преобразуем Data в строку и вызываем замыкание с идентификатором друга и текстом сообщения
  if let messageStr = String(data: messageData, encoding: .utf8) {
    context.callback(Int32(friendNumber), messageStr)
  }
}
