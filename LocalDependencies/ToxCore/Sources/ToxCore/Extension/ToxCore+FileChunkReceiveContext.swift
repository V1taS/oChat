//
//  ToxCore+FileChunkReceiveContext.swift
//
//
//  Created by Vitalii Sosin on 10.06.2024.
//

import Foundation
import ToxCoreCpp

// Класс для хранения контекста при получении частей файла
/// Класс для хранения контекста и обработки обратных вызовов при получении частей файла.
/// - `callback`: Замыкание, которое будет вызвано при получении части файла.
/// - `init(callback:)`: Инициализирует объект с переданным замыканием.
final class FileChunkReceiveContext {
  var callback: (Int32, Int32, UInt64, Data) -> Void
  
  /// Инициализирует объект `FileChunkReceiveContext` с заданным замыканием.
  /// - Parameter callback: Замыкание, которое будет вызвано при получении части файла. Замыкание принимает следующие параметры:
  ///   - `friendId`: Уникальный идентификатор друга, от которого поступила часть файла.
  ///   - `fileId`: Уникальный идентификатор файла.
  ///   - `position`: Позиция начала данных в файле.
  ///   - `fileData`: Данные файла в виде `Data`.
  init(callback: @escaping (Int32, Int32, UInt64, Data) -> Void) {
    self.callback = callback
  }
}

// Глобальная переменная для хранения контекста
var globalConnectionFileChunkReceiveContext: FileChunkReceiveContext?

// Глобальная функция обратного вызова для обработки получения частей файла
/// Глобальная функция для обработки получения частей файла от друзей в сети Tox.
/// Эта функция регистрируется в Tox как коллбек и вызывается при получении данных части файла.
/// - Parameters:
///   - tox: Указатель на текущий объект Tox.
///   - friendId: Уникальный идентификатор друга, отправившего файл.
///   - fileId: Уникальный идентификатор файла.
///   - position: Позиция начала данных в файле.
///   - data: Указатель на байты данных части файла. Если значение nil, данных нет.
///   - length: Длина данных части файла в байтах.
///   - userData: Указатель на пользовательские данные, переданные вместе с коллбеком.
let fileChunkReceiveCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?,
  UInt32,
  UInt32,
  UInt64,
  UnsafePointer<UInt8>?,
  Int,
  UnsafeMutableRawPointer?
) -> Void = { tox, friendId, fileId, position, data, length, userData in
  // Проверяем, что указатель на данные не равен nil и длина данных больше нуля
  guard let data = data, length > 0 else { return }
  
  // Получаем контекст
  guard let context = globalConnectionFileChunkReceiveContext else {
    assertionFailure("Ошибка: контекст не установлен")
    return
  }
  
  // Создаем Data из указателя на байты данных части файла
  let fileData = Data(bytes: data, count: Int(length))
  
  // Вызываем замыкание с идентификаторами друга и файла, позицией и данными файла
  context.callback(Int32(friendId), Int32(fileId), position, fileData)
}
