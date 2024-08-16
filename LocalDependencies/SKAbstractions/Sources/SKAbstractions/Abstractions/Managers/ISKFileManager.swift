//
//  ISKFileManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import Foundation

/// Протокол для управления файлами.
public protocol ISKFileManager {
  /// Сохраняет объект в кэш.
  /// - Parameters:
  ///   - fileName: Имя файла.
  ///   - fileExtension: Расширение файла.
  ///   - data: Данные для сохранения.
  /// - Returns: URL сохраненного файла или nil в случае ошибки.
  func saveObjectToCachesWith(fileName: String, fileExtension: String, data: Data) -> URL?
  
  /// Сохраняет объект.
  /// - Parameters:
  ///   - fileName: Имя файла.
  ///   - fileExtension: Расширение файла.
  ///   - data: Данные для сохранения.
  /// - Returns: URL сохраненного файла или nil в случае ошибки.
  func saveObjectWith(fileName: String, fileExtension: String, data: Data) -> URL?
  
  /// Читает объект из файла.
  /// - Parameter fileURL: URL файла.
  /// - Returns: Данные из файла или nil в случае ошибки.
  func readObjectWith(fileURL: URL) -> Data?
  
  /// Очищает временный каталог.
  func clearTemporaryDirectory()
  
  /// Сохраняет объект с временным URL.
  /// - Parameter tempURL: Временный URL.
  /// - Returns: URL сохраненного файла или nil в случае ошибки.
  func saveObjectWith(tempURL: URL) -> URL?
  
  /// Возвращает имя файла из URL.
  /// - Parameter url: URL файла.
  /// - Returns: Имя файла или nil в случае ошибки.
  func getFileName(from url: URL) -> String?
  
  /// Возвращает имя файла без расширения из URL.
  /// - Parameter url: URL файла.
  /// - Returns: Имя файла без расширения.
  func getFileNameWithoutExtension(from url: URL) -> String
  
  /// Получает первый кадр из видеофайла.
  /// - Parameter url: URL видеофайла.
  /// - Returns: Данные первого кадра или nil в случае ошибки.
  func getFirstFrame(from url: URL) -> Data?
  
  /// Изменяет размер миниатюры кадра.
  /// - Parameter data: Данные кадра.
  /// - Returns: Данные измененной миниатюры или nil в случае ошибки.
  func resizeThumbnailImageWithFrame(data: Data) -> Data?
  
  /// Получает и распаковывает файл.
  /// - Parameters:
  ///   - zipFileURL: URL zip-файла.
  ///   - password: Пароль для распаковки.
  func receiveAndUnzipFile(
    zipFileURL: URL,
    password: String,
    completion: @escaping (Result<(
      model: MessengerNetworkRequestModel,
      recordingDTO: MessengeRecordingDTO?,
      files: [URL]
    ), Error>) -> Void
  )
}
