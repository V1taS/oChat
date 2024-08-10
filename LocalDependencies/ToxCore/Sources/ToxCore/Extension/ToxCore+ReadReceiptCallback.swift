//
//  ToxCore+ReadReceiptCallback.swift
//  ToxCore
//
//  Created by Vitalii Sosin on 16.06.2024.
//

import Foundation
import ToxCoreCpp

/// Класс для хранения контекста уведомлений о прочтении сообщений и обработки обратных вызовов.
/// - callback: Замыкание, которое будет вызвано при получении уведомления о прочтении.
/// - init(callback:): Инициализирует объект с переданным замыканием.
final class ReadReceiptContext {
  var callback: (UInt32, UInt32) -> Void
  
  /// Инициализирует объект ReadReceiptContext с заданным замыканием.
  /// - Parameter callback: Замыкание, которое будет вызвано при получении уведомления о прочтении.
  init(callback: @escaping (UInt32, UInt32) -> Void) {
    self.callback = callback
  }
}

/// Глобальная переменная для хранения контекста уведомлений о прочтении.
var globalReadReceiptContext: ReadReceiptContext?

/// Глобальная функция для обработки уведомлений о прочтении сообщений друзьями в сети Tox.
/// Эта функция регистрируется в Tox как коллбэк и вызывается при получении уведомления.
/// - Parameters:
///   - tox: Указатель на текущий объект Tox.
///   - friendNumber: Уникальный идентификатор друга, который прочитал сообщение.
///   - messageId: Идентификатор сообщения, которое было прочитано.
///   - userData: Указатель на пользовательские данные, переданные вместе с коллбэком.
let friendReadReceiptCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?,
  UInt32,
  UInt32,
  UnsafeMutableRawPointer?
) -> Void = { tox, friendNumber, messageId, userData in
  // Получаем контекст из глобальной переменной
  guard let context = globalReadReceiptContext else {
    assertionFailure("Ошибка: контекст не установлен")
    return
  }
  
  // Вызываем замыкание с идентификатором друга и идентификатором сообщения
  context.callback(friendNumber, messageId)
}
