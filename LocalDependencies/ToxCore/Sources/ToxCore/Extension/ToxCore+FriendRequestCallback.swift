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
  // Проверяем, что публичный ключ не равен nil и длина сообщения допустима (неотрицательная)
  guard let publicKey = publicKey, length >= 0 else {
    assertionFailure("Ошибка: Публичный ключ не установлен или длина сообщения некорректна.")
    return
  }
  
  // Получаем контекст из глобальной переменной
  guard let context = globalConnectioFriendRequestContext else {
    assertionFailure("Ошибка: контекст не установлен")
    return
  }
  
  // Преобразуем публичный ключ в Data
  let publicKeyData = Data(bytes: publicKey, count: Int(TOX_PUBLIC_KEY_SIZE))
  
  // Инициализируем Data для сообщения, даже если оно пустое
  let messageData: Data
  if length > 0, let message = message {
    messageData = Data(bytes: message, count: length)
  } else {
    messageData = Data()
  }
  
  // Преобразуем публичный ключ в шестнадцатеричную строку
  let publicKeyHex = publicKeyData.map { String(format: "%02x", $0) }.joined()
  
  // Преобразуем сообщение в строку UTF-8, если оно не пустое
  let messageStr = String(data: messageData, encoding: .utf8) ?? ""
  
  // Вызываем сохраненное замыкание с публичным ключом и сообщением
  context.callback(publicKeyHex, messageStr)
}
