//
//  ZipArchiveService.swift
//  oChat
//
//  Created by Vitalii Sosin on 15.05.2025.
//  Copyright © 2025 SosinVitalii.com.
//

import Foundation
import ZipArchive

// MARK: - ZipArchiveService

/// Сервис для архивации и разархивации данных с помощью **SSZipArchive**.
/// При архивации создаёт `.crypto`‑файл во временной директории.
public final class ZipArchiveService {
  // MARK: Singleton
  public static let shared = ZipArchiveService()

  // MARK: - Private
  private let staticPart = "!M3uT86Rr$hHtC5B)aMl56(0TM#x)Khw4q%L@4%@2h#2RG1p^5"
  private let fileManager = FileManager.default

  // MARK: - Init
  private init() {}

  // MARK: - Zipping

  /// Сжимает массив данных и возвращает URL созданного `.crypto`‑файла.
  /// - Parameters:
  ///   - files: Кортежи `(name: String, data: Data)` — имя, под которым файл будет храниться в архиве, и сами данные.
  ///   - archiveName: Имя архива *без* расширения.
  ///   - password: Пользовательская часть пароля.
  ///   - progress: Коллбэк прогресса `[0.0 … 1.0]` (всегда на `MainActor`).
  /// - Returns: URL созданного `.crypto`‑файла во временной папке.
  public func zipFiles(
    files: [(name: String, data: Data)],
    archiveName: String,
    password: String,
    progress: ((Double) -> Void)? = nil
  ) async throws -> URL {
    guard !files.isEmpty else { throw ZipArchiveServiceError.invalidParameters }

    return try await withCheckedThrowingContinuation { continuation in
      Task.detached(priority: .userInitiated) { [self] in
        let mergedPassword = staticPart + password
        let tempZipURL = fileManager.temporaryDirectory.appendingPathComponent("\(archiveName).zip")
        let zip = SSZipArchive(path: tempZipURL.path)

        guard zip.open() else {
          return continuation.resume(throwing: ZipArchiveServiceError.cannotOpenArchive)
        }

        // Временные пути для данных, которые нужно будет удалить после архивации
        var tempDataURLs: [URL] = []
        defer { tempDataURLs.forEach { try? fileManager.removeItem(at: $0) } }

        let total = files.count
        var current = 0

        for file in files {
          current += 1

          // Записываем `Data` во временный файл, т.к. ZipArchive работает с путями
          let tempFileURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
          do {
            try file.data.write(to: tempFileURL)
            tempDataURLs.append(tempFileURL)
          } catch {
            zip.close()
            return continuation.resume(throwing: ZipArchiveServiceError.cannotCopyFile)
          }

          let ok = zip.writeFile(
            atPath: tempFileURL.path,
            withFileName: file.name,
            compressionLevel: 0,
            password: mergedPassword,
            aes: true
          )

          if !ok {
            zip.close()
            return continuation.resume(throwing: ZipArchiveServiceError.cannotAddFile)
          }

          if let progress {
            await MainActor.run { progress(Double(current) / Double(total)) }
          }
        }

        zip.close()

        // Итоговый `.crypto`
        let cryptoURL = fileManager.temporaryDirectory.appendingPathComponent("\(archiveName).crypto")
        do {
          try moveFile(at: tempZipURL, to: cryptoURL)
          continuation.resume(returning: cryptoURL)
        } catch {
          continuation.resume(throwing: ZipArchiveServiceError.cannotMoveFile)
        }
      }
    }
  }

  // MARK: - Unzipping

  /// Распаковывает `.crypto`‑файл и возвращает массив `(name: String, data: Data)`.
  /// - Parameters:
  ///   - path: Путь к `.crypto`‑файлу.
  ///   - password: Пользовательская часть пароля.
  ///   - progress: Коллбэк прогресса `[0.0 … 1.0]` (всегда на `MainActor`).
  /// - Returns: Массив извлечённых файлов.
  public func unzipFile(
    atPath path: URL,
    password: String,
    progress: ((Double) -> Void)? = nil
  ) async throws -> [(name: String, data: Data)] {
    return try await withCheckedThrowingContinuation { continuation in
      Task.detached(priority: .userInitiated) { [self] in
        let mergedPassword = staticPart + password

        // Дублируем входной файл, чтобы оригинал остался нетронутым.
        let tempZipURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".zip")
        do {
          try copyFile(at: path, to: tempZipURL)
        } catch {
          return continuation.resume(throwing: ZipArchiveServiceError.cannotCopyFile)
        }

        let tempUnzipDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        var results: [(name: String, data: Data)] = []

        let ok = SSZipArchive.unzipFile(
          atPath: tempZipURL.path,
          toDestination: tempUnzipDir.path,
          overwrite: true,
          password: mergedPassword,
          progressHandler: { entry, _, entryNum, total in
            let fileURL = tempUnzipDir.appendingPathComponent(entry)
            if let fileData = try? Data(contentsOf: fileURL) {
              results.append((name: entry, data: fileData))
            }
            if let progress {
              Task { await MainActor.run { progress(Double(entryNum) / Double(total)) } }
            }
          },
          completionHandler: { _, success, error in
            defer { try? fileManager.removeItem(at: tempZipURL) }

            if let error = error {
              return continuation.resume(throwing: ZipArchiveServiceError.unknown(error as NSError))
            }
            guard success else {
              return continuation.resume(throwing: ZipArchiveServiceError.cannotUnzip)
            }

            continuation.resume(returning: results)
          }
        )

        if !ok {
          continuation.resume(throwing: ZipArchiveServiceError.cannotUnzip)
        }
      }
    }
  }

  // MARK: - Helpers

  private func moveFile(at source: URL, to destination: URL) throws {
    if fileManager.fileExists(atPath: destination.path) {
      try fileManager.removeItem(at: destination)
    }
    try fileManager.moveItem(at: source, to: destination)
  }

  private func copyFile(at source: URL, to destination: URL) throws {
    if fileManager.fileExists(atPath: destination.path) {
      try fileManager.removeItem(at: destination)
    }
    try fileManager.copyItem(at: source, to: destination)
  }
}

// MARK: - Error

/// Ошибки, которые может вернуть `ZipArchiveService`.
public enum ZipArchiveServiceError: LocalizedError {
  case cannotOpenArchive
  case cannotAddFile
  case cannotMoveFile
  case cannotCopyFile
  case cannotUnzip
  case invalidParameters
  case unknown(NSError)

  public var errorDescription: String? {
    switch self {
    case .cannotOpenArchive:
      return "Не удалось открыть ZIP-архив."
    case .cannotAddFile:
      return "Не удалось добавить файл в ZIP-архив."
    case .cannotMoveFile:
      return "Не удалось переместить файл."
    case .cannotCopyFile:
      return "Не удалось скопировать файл."
    case .cannotUnzip:
      return "Не удалось распаковать ZIP-архив."
    case .invalidParameters:
      return "Неверные параметры вызова ZipArchiveService."
    case .unknown(let error):
      return error.localizedDescription
    }
  }
}
