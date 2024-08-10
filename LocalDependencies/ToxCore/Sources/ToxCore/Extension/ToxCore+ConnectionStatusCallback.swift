//
//  ToxCore+ConnectionStatusCallback.swift
//  ToxCore
//
//  Created by Vitalii Sosin on 11.06.2024.
//


import Foundation
import ToxCoreCpp

// Тип данных для хранения контекста статуса соединения
/// Класс для хранения контекста статуса соединения и обработки обратных вызовов.
/// - `callback`: Замыкание, которое будет вызвано при изменении статуса соединения.
/// - `init(callback:)`: Инициализирует объект с переданным замыканием.
final class ConnectionStatusContext {
  var callback: (ConnectionStatus) -> Void
  
  /// Инициализирует объект `ConnectionStatusContext` с заданным замыканием.
  /// - Parameter callback: Замыкание, которое будет вызвано при изменении статуса соединения.
  init(callback: @escaping (ConnectionStatus) -> Void) {
    self.callback = callback
  }
}

// Глобальная переменная для хранения контекста
var globalConnectionStatusContext: ConnectionStatusContext?

// Глобальная функция обратного вызова для обработки изменений статуса соединения
/// Глобальная функция для обработки изменений статуса соединения в сети Tox.
/// Эта функция регистрируется в Tox как коллбек и вызывается при изменении статуса соединения.
/// - Parameters:
///   - tox: Указатель на текущий объект Tox.
///   - status: Новый статус соединения.
///   - userData: Указатель на пользовательские данные, переданные вместе с коллбеком.
let connectionStatusCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?,
  TOX_CONNECTION,
  UnsafeMutableRawPointer?
) -> Void = { tox, status, userData in
  guard let context = globalConnectionStatusContext else {
    assertionFailure("Ошибка: контекст не установлен")
    return
  }
  
  let connectionStatus = ConnectionStatus(from: status)
  context.callback(connectionStatus)
}
