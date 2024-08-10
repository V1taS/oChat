//
//  ToxCore+TypingContextCallback.swift
//  ToxCore
//
//  Created by Vitalii Sosin on 16.06.2024.
//

import Foundation
import ToxCoreCpp

/// Класс для хранения контекста статуса набора текста и обработки обратных вызовов.
/// - callback: Замыкание, которое будет вызвано при изменении статуса набора текста.
/// - init(callback:): Инициализирует объект с переданным замыканием.
final class TypingContext {
  var callback: (Int32, Bool) -> Void
  
  /// Инициализирует объект TypingContext с заданным замыканием.
  /// - Parameter callback: Замыкание, которое будет вызвано при изменении статуса набора текста.
  init(callback: @escaping (Int32, Bool) -> Void) {
    self.callback = callback
  }
}

/// Глобальная переменная для хранения контекста набора текста.
var globalTypingContext: TypingContext?

/// Глобальная функция для обработки изменений статуса набора текста друзей в сети Tox.
/// Эта функция регистрируется в Tox как коллбэк и вызывается при изменении статуса.
/// - Parameters:
///   - tox: Указатель на текущий объект Tox.
///   - friendNumber: Уникальный идентификатор друга, чей статус набора текста изменился.
///   - isTyping: Логическое значение, указывающее, набирает ли текст друг.
///   - userData: Указатель на пользовательские данные, переданные вместе с коллбэком.
let friendTypingCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?,
  UInt32,
  Bool,
  UnsafeMutableRawPointer?
) -> Void = { tox, friendNumber, isTyping, userData in
  // Получаем контекст из глобальной переменной
  guard let context = globalTypingContext else {
    assertionFailure("Ошибка: контекст не установлен")
    return
  }
  
  // Вызываем замыкание с идентификатором друга и статусом набора текста
  context.callback(Int32(friendNumber), isTyping)
}
