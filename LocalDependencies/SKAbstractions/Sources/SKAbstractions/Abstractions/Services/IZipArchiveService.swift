//
//  IZipArchiveService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 02.07.2024.
//

import Foundation

public protocol IZipArchiveService {
  /// Метод для архивирования файлов
  ///
  /// - Parameters:
  ///   - paths: Массив URL путей к файлам, которые необходимо заархивировать.
  ///   - destinationPath: URL путь, куда сохранить созданный zip-файл.
  ///   - password: (Опционально) Пароль для архивирования.
  ///   - progress: (Опционально) Замыкание для отслеживания прогресса.
  /// - Throws: Выбрасывает ошибку, если архивирование не удалось.
  func zipFiles(
    atPaths paths: [URL],
    toDestination destinationPath: URL,
    password: String?,
    progress: ((_ progress: Double) -> ())?
  ) throws
  
  /// Метод для разархивирования файлов
  ///
  /// - Parameters:
  ///   - path: URL путь к zip-файлу, который нужно разархивировать.
  ///   - destinationPath: URL путь, куда нужно разархивировать содержимое.
  ///   - overwrite: (Опционально) Флаг перезаписи существующих файлов.
  ///   - password: (Опционально) Пароль для разархивирования.
  ///   - progress: (Опционально) Замыкание для отслеживания прогресса.
  ///   - fileOutputHandler: (Опционально) Обработчик для каждого разархивированного файла.
  /// - Throws: Выбрасывает ошибку, если разархивирование не удалось.
  func unzipFile(
    atPath path: URL,
    toDestination destinationPath: URL,
    overwrite: Bool,
    password: String?,
    progress: ((_ progress: Double) -> ())?,
    fileOutputHandler: ((_ unzippedFile: URL) -> Void)?
  ) throws
}
