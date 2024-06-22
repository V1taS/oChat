//
//  ToxCore+FriendRequestCallback.swift
//
//
//  Created by Vitalii Sosin on 09.06.2024.
//

import Foundation
import ToxCoreCpp

// Тип данных для хранения пользовательских данных
/// Класс, предназначенный для хранения контекста запросов на добавление в друзья.
/// Содержит замыкание, которое будет вызвано при получении нового запроса на добавление в друзья.
final class FriendRequestContext {
  /// Замыкание, принимающее два параметра: публичный ключ друга в виде строки и сообщение.
  var callback: (String, String) -> Void
  
  /// Инициализатор, принимающий замыкание для обработки запросов на добавление в друзья.
  /// - Parameter callback: Замыкание, вызываемое при получении запроса на добавление в друзья.
  init(callback: @escaping (String, String) -> Void) {
    self.callback = callback
  }
}

// Глобальная переменная для хранения контекста
var globalConnectioFriendRequestContext: FriendRequestContext?

// Глобальная функция обратного вызова для обработки запросов на добавление в друзья
// Указываем, что это C-функция с @convention(c)
/// Глобальная функция обратного вызова, предназначенная для обработки запросов на добавление в друзья.
/// Эта функция вызывается библиотекой Tox при получении запроса на добавление в друзья.
/// - Parameters:
///   - tox: Указатель на объект Tox.
///   - publicKey: Указатель на публичный ключ отправителя запроса.
///   - message: Указатель на сообщение, прикрепленное к запросу.
///   - length: Длина сообщения.
///   - userData: Указатель на пользовательские данные, переданные при регистрации обратного вызова.
let friendRequestCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?,
  UnsafePointer<UInt8>?,
  UnsafePointer<UInt8>?,
  Int,
  UnsafeMutableRawPointer?
) -> Void = { tox, publicKey, message, length, userData in
  // Проверяем, что публичный ключ и сообщение не равны nil, а длина сообщения больше нуля.
  guard let publicKey = publicKey, let message = message, length > 0 else { return }
  
  // Получаем указатель на пользовательские данные и проверяем его на nil.
  guard let userData = userData else { return }
  
  guard let context = globalConnectioFriendRequestContext else {
    print("🔴 Ошибка: контекст не установлен")
    return
  }
  
  // Преобразуем публичный ключ и сообщение в формат Data.
  let publicKeyData = Data(bytes: publicKey, count: Int(TOX_PUBLIC_KEY_SIZE))
  let messageData = Data(bytes: message, count: length)
  
  // Конвертируем публичный ключ в шестнадцатеричную строку и сообщение в строку UTF-8.
  if let publicKeyHex = publicKeyData.toHexString(),
     let messageStr = String(data: messageData, encoding: .utf8) {
    // Вызываем сохраненное замыкание с публичным ключом и сообщением.
    context.callback(publicKeyHex, messageStr)
  }
}
