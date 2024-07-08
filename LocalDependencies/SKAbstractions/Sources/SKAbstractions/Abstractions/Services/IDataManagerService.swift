//
//  IDataManagerService.swift
//
//
//  Created by Vitalii Sosin on 26.02.2024.
//

import Foundation

/// Протокол для сервиса управления данными.
public protocol IDataManagerService {
  
  /// Сохранить объект
  /// - Parameters:
  ///  - fileName: Название файла
  ///  - fileExtension: Расширение файла `.txt`
  ///  - data: Файл для записи
  /// - Returns: Путь до файла `URL`
  func saveObjectWith(
    fileName: String,
    fileExtension: String,
    data: Data
  ) -> URL?
  
  /// Сохранить объект в кеш
  /// - Parameters:
  ///  - fileName: Название файла
  ///  - fileExtension: Расширение файла `.txt`
  ///  - data: Файл для записи
  /// - Returns: Путь до файла `URL`
  func saveObjectToCachesWith(
    fileName: String,
    fileExtension: String,
    data: Data
  ) -> URL?
  
  /// Получить объект
  /// - Parameter fileURL: Путь к файлу
  /// - Returns: Путь до файла `URL`
  func readObjectWith(fileURL: URL) -> Data?
  
  /// Удалить объект
  /// - Parameters:
  ///  - fileURL: Путь к файлу
  ///  - isRemoved: Удален объект или нет
  /// - Returns: Путь до файла `URL`
  func deleteObjectWith(fileURL: URL, isRemoved: ((Bool) -> Void)?)
  
  /// Очищает временную директорию.
  func clearTemporaryDirectory()
  
  /// Сохраняет объект по указанному временному URL и возвращает новый URL сохраненного объекта.
  /// - Parameter tempURL: Временный URL, по которому сохраняется объект.
  /// - Returns: Новый URL сохраненного объекта или nil в случае ошибки.
  func saveObjectWith(tempURL: URL) -> URL?
  
  /// Получить URL на файл по имени файла
  func constructFileURL(fileName: String, fileExtension: String?) -> URL?
  
  /// Получить имя файла по URL
  func getFileName(from url: URL) -> String?
  
  /// Получить имя файла по URL без расширения
  func getFileNameWithoutExtension(from url: URL) -> String
}
