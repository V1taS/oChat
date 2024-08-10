//
//  ToxCore+FileReceiveContext.swift
//
//
//  Created by Vitalii Sosin on 10.06.2024.
//

import Foundation
import ToxCoreCpp

// Класс для хранения контекста при приеме файлов
/// Класс для хранения контекста и обработки обратных вызовов при приеме файлов.
/// - `callback`: Замыкание, которое будет вызвано при получении файла.
/// - `init(callback:)`: Инициализирует объект с переданным замыканием.
final class FileReceiveContext {
  var callback: (Int32, Int32, String, UInt64) -> Void
  
  /// Инициализирует объект `FileReceiveContext` с заданным замыканием.
  /// - Parameter callback: Замыкание, которое будет вызвано при получении файла. Замыкание принимает следующие параметры:
  ///   - `friendId`: Уникальный идентификатор друга, от которого поступил файл.
  ///   - `fileId`: Уникальный идентификатор файла.
  ///   - `fileName`: Имя файла.
  ///   - `fileSize`: Размер файла в байтах.
  init(callback: @escaping (Int32, Int32, String, UInt64) -> Void) {
    self.callback = callback
  }
}

// Глобальная переменная для хранения контекста
var globalConnectionFileReceiveContext: FileReceiveContext?

// Глобальная функция обратного вызова для обработки получения файлов
/// Глобальная функция для обработки получения файлов от друзей в сети Tox.
/// Эта функция регистрируется в Tox как коллбек и вызывается при получении запроса на отправку файла.
/// - Parameters:
///   - tox: Указатель на текущий объект Tox.
///   - friendId: Уникальный идентификатор друга, отправившего файл.
///   - fileId: Уникальный идентификатор файла.
///   - kind: Тип файла (обычные данные или аватар, и т.д.).
///   - fileSize: Размер файла в байтах.
///   - fileName: Указатель на байты имени файла. Если значение nil, имя файла не было получено.
///   - fileNameLength: Длина имени файла в байтах.
///   - userData: Указатель на пользовательские данные, переданные вместе с коллбеком.
let fileReceiveCallback: @convention(c) (
  UnsafeMutablePointer<Tox>?,
  UInt32,
  UInt32,
  UInt32,
  UInt64,
  UnsafePointer<UInt8>?,
  Int,
  UnsafeMutableRawPointer?
) -> Void = { tox, friendId, fileId, kind, fileSize, fileName, fileNameLength, userData in
  // Проверяем, что указатель на имя файла не равен nil и длина имени больше нуля
  guard let fileName, fileNameLength > 0 else { return }
  
  // Получаем контекст
  guard let context = globalConnectionFileReceiveContext else {
    assertionFailure("Ошибка: контекст не установлен")
    return
  }
  
  // Создаем Data из указателя на байты имени файла
  let fileNameData = Data(bytes: fileName, count: Int(fileNameLength))
  
  // Преобразуем Data в строку и вызываем замыкание с идентификаторами друга и файла, именем файла и размером файла
  if let fileNameStr = String(data: fileNameData, encoding: .utf8) {
    context.callback(Int32(friendId), Int32(fileId), fileNameStr, fileSize)
  }
}
