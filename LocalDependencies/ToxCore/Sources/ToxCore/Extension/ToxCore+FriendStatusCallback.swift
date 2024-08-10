//
//  ToxCore+FriendStatusCallback.swift
//
//
//  Created by Vitalii Sosin on 09.06.2024.
//

import Foundation
import ToxCoreCpp

// Тип данных для хранения контекста состояния друзей
/// Класс для хранения контекста состояния друзей и обработки обратных вызовов.
/// - `callback`: Замыкание, которое будет вызвано при изменении состояния подключения друга.
/// - `init(callback:)`: Инициализирует объект с переданным замыканием.
final class FriendStatusContext {
  var callback: (Int32, ConnectionStatus) -> Void
  
  /// Инициализирует объект `FriendStatusContext` с заданным замыканием.
  /// - Parameter callback: Замыкание, которое будет вызвано при изменении состояния подключения друга.
  init(callback: @escaping (Int32, ConnectionStatus) -> Void) {
    self.callback = callback
  }
}

// Глобальная переменная для хранения контекста
var globalFriendStatusContext: FriendStatusContext?

// Глобальная функция обратного вызова для обработки изменений состояния подключения друзей
/// Глобальная функция для обработки изменений состояния подключения друзей в сети Tox.
/// Эта функция регистрируется в Tox как callback и вызывается при изменении состояния подключения.
/// - Parameters:
///   - tox: Указатель на текущий объект Tox.
///   - friendNumber: Уникальный идентификатор друга, состояние которого изменилось.
///   - connectionStatus: Новое состояние подключения друга.
///   - userData: Указатель на пользовательские данные, переданные вместе с callback.
let friendStatusCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?,
  Tox_Friend_Number,
  TOX_CONNECTION,
  UnsafeMutableRawPointer?
) -> Void = { tox, friendNumber, connectionStatus, userData in
  // Получаем контекст из пользовательских данных
  guard let context = globalFriendStatusContext else {
    assertionFailure("Ошибка: контекст не установлен")
    return
  }
  
  // Преобразуем статус подключения в ConnectionStatus
  if let status = ConnectionStatus.fromCConnectionStatus(connectionStatus) {
    // Вызываем замыкание с идентификатором друга и его новым состоянием подключения
    context.callback(Int32(friendNumber), status)
  }
}
