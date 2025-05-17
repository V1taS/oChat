//
//  MediaAttachment.swift
//  oChat
//
//  Created by Vitalii Sosin on 15.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

public typealias MediaAttachmentData = MediaAttachment<Data>
public typealias MediaAttachmentURL = MediaAttachment<URL>

/// Обобщённый контейнер для вложений.
/// P ‒ тип полезной нагрузки (Data, URL, String, …), обязан быть Codable.
public enum MediaAttachment<P: Codable>: Codable {
  /// Набор изображений (например, несколько фото или слайд-шоу).
  case images([P])
  /// Набор видеороликов.
  case videos([P])
  /// Одна аудио-/видеозапись (voice message и т. п.).
  case recording(P)
  /// Произвольный файл любого типа (PDF, архив, документ и т. п.).
  case files([P])

  // MARK: – Codable

  private enum CodingKeys: String, CodingKey { case kind, payload }
  private enum Kind: String, Codable { case images, videos, recording, files }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .images(let value):
      try container.encode(Kind.images, forKey: .kind)
      try container.encode(value, forKey: .payload)

    case .videos(let value):
      try container.encode(Kind.videos, forKey: .kind)
      try container.encode(value, forKey: .payload)

    case .recording(let value):
      try container.encode(Kind.recording, forKey: .kind)
      try container.encode(value, forKey: .payload)

    case .files(let value):
      try container.encode(Kind.files, forKey: .kind)
      try container.encode(value, forKey: .payload)
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let kind = try container.decode(Kind.self, forKey: .kind)

    switch kind {
    case .images:
      self = .images(try container.decode([P].self, forKey: .payload))
    case .videos:
      self = .videos(try container.decode([P].self, forKey: .payload))
    case .recording:
      self = .recording(try container.decode(P.self, forKey: .payload))
    case .files:
      self = .files(try container.decode([P].self, forKey: .payload))
    }
  }
}

// MARK: - Ошибка преобразования

/// Возможные ошибки при конвертации `MediaAttachmentURL` в `MediaAttachmentData`.
public enum MediaAttachmentMappingError: Error {
  /// Не удалось считать данные по одному из URL.
  case dataLoadingFailed(URL, underlying: Error)
}

// MARK: - Асинхронное преобразование URL-вложений в Data-вложения

public extension MediaAttachment where P == URL {

  /// Преобразует `MediaAttachment<URL>` в `MediaAttachment<Data>`, асинхронно считывая данные из файловых/сетевых URL.
  ///
  /// - Returns: `MediaAttachment<Data>` с тем же набором вложений, но в виде `Data`.
  /// - Throws: `MediaAttachmentMappingError`, если чтение какого-либо URL завершилось ошибкой.
  @available(iOS 15.0, *)
  func mapToData() async throws -> MediaAttachment<Data> {

    // Вспомогательная функция для параллельной загрузки массивов URL.
    func load(_ urls: [URL]) async throws -> [Data] {
      try await withThrowingTaskGroup(of: (URL, Data).self) { group in
        // Стартуем параллельные задачи
        for url in urls {
          group.addTask {
            do {
              return (url, try Data(contentsOf: url))
            } catch {
              throw MediaAttachmentMappingError.dataLoadingFailed(url, underlying: error)
            }
          }
        }

        // Собираем результаты
        var result = Array<Data>()
        for try await (_, data) in group {
          result.append(data)
        }
        return result
      }
    }

    // Конкретное сопоставление кейсов
    switch self {
    case .images(let urls):
      return .images(try await load(urls))

    case .videos(let urls):
      return .videos(try await load(urls))

    case .recording(let url):
      do {
        return .recording(try Data(contentsOf: url))
      } catch {
        throw MediaAttachmentMappingError.dataLoadingFailed(url, underlying: error)
      }

    case .files(let urls):
      return .files(try await load(urls))
    }
  }
}

// MARK: – Equatable

extension MediaAttachment: Equatable where P: Equatable {}
