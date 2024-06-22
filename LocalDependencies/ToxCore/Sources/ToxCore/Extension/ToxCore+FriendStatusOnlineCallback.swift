//
//  ToxCore+FriendStatusOnlineCallback.swift
//  ToxCore
//
//  Created by Vitalii Sosin on 16.06.2024.
//

import Foundation
import ToxCoreCpp

/// Класс для хранения контекста статуса и обработки обратных вызовов.
/// - callback: Замыкание, которое будет вызвано при изменении статуса.
/// - init(callback:): Инициализирует объект с переданным замыканием.
final class FriendStatusOnlineContext {
  var callback: (Int32, UserStatus) -> Void
  
  /// Инициализирует объект StatusContext с заданным замыканием.
  /// - Parameter callback: Замыкание, которое будет вызвано при изменении статуса.
  init(callback: @escaping (Int32, UserStatus) -> Void) {
    self.callback = callback
  }
}

/// Глобальная переменная для хранения контекста статуса.
var globalFriendStatusOnlineContext: FriendStatusOnlineContext?

/// Глобальная функция для обработки изменений статуса друзей в сети Tox.
/// Эта функция регистрируется в Tox как коллбэк и вызывается при изменении статуса.
/// - Parameters:
///   - tox: Указатель на текущий объект Tox.
///   - friendNumber: Уникальный идентификатор друга, чей статус изменился.
///   - status: Новый статус пользователя.
///   - userData: Указатель на пользовательские данные, переданные вместе с коллбеком.
let friendStatusOnlineCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?,
  UInt32,
  TOX_USER_STATUS,
  UnsafeMutableRawPointer?
) -> Void = { tox, friendNumber, status, userData in
  // Получаем контекст из глобальной переменной
  guard let context = globalFriendStatusOnlineContext else {
    print("🔴 Ошибка: контекст не установлен")
    return
  }
  
  // Преобразуем статус из C-типов в Swift-тип
  let userStatus: UserStatus
  switch status {
  case TOX_USER_STATUS_NONE:
    userStatus = .online
  case TOX_USER_STATUS_AWAY:
    userStatus = .away
  case TOX_USER_STATUS_BUSY:
    userStatus = .busy
  default:
    return
  }
  
  // Вызываем замыкание с идентификатором друга и новым статусом
  context.callback(Int32(friendNumber), userStatus)
}
