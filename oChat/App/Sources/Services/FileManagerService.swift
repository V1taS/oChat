//
//  FileManagerService.swift
//  oChat
//
//  Created by Vitalii Sosin on 15.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

/// Сервис для безопасного хранения файлов в скрытой папке приложения.
/// Данные сохраняются в `Application Support/.ochatStorage`, не попадают в iCloud-бэкап
/// и не удаляются системой.
public actor FileManagerService {

  // MARK: – Singleton

  public static let shared = FileManagerService()

  // MARK: – Private

  private let directoryName = ".ochatStorage"
  private let fileManager = FileManager.default
  private var directoryURL: URL

  // MARK: – Init

  private init() {
    // 1. Определяем базовый каталог Application Support
    let baseURL = fileManager.urls(for: .applicationSupportDirectory,
                                   in: .userDomainMask).first!

    // 2. Формируем путь к нашей скрытой директории
    directoryURL = baseURL.appendingPathComponent(directoryName,
                                                  isDirectory: true)

    // 3. Создаём её при первом запуске
    try? fileManager.createDirectory(at: directoryURL,
                                     withIntermediateDirectories: true)

    // 4. Исключаем папку из iCloud-бэкапа
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try? directoryURL.setResourceValues(values)
  }

  // MARK: – API

  /// Сохраняет `Data` в файл и возвращает итоговый `URL`.
  /// - Parameters:
  ///   - data: Данные для записи.
  ///   - fileName: Имя файла (по умолчанию `UUID().uuidString`).
  /// - Returns: Путь к сохранённому файлу.
  public func save(_ data: Data,
                   fileName: String = UUID().uuidString) async throws -> URL {
    let url = directoryURL.appendingPathComponent(fileName)
    try data.write(to: url, options: .atomic)
    return url
  }

  /// Копирует файл из `sourceURL` в скрытую папку и возвращает новый `URL`.
  /// - Parameter sourceURL: Исходный путь к файлу.
  /// - Returns: Новый путь внутри скрытой директории.
  public func save(fileAt sourceURL: URL) async throws -> URL {
    let destinationURL = directoryURL.appendingPathComponent(sourceURL.lastPathComponent)

    // Заменяем файл, если он уже существует
    if fileManager.fileExists(atPath: destinationURL.path) {
      try fileManager.removeItem(at: destinationURL)
    }

    try fileManager.copyItem(at: sourceURL, to: destinationURL)
    return destinationURL
  }

  /// Удаляет **все** файлы из скрытой папки.
  public func removeAll() async throws {
    let items = try fileManager.contentsOfDirectory(at: directoryURL,
                                                    includingPropertiesForKeys: nil)
    for url in items {
      try fileManager.removeItem(at: url)
    }
  }

  /// Возвращает путь к скрытой директории (на всякий случай).
  public func containerURL() async -> URL {
    directoryURL
  }
}
