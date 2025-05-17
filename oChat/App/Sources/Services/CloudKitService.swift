//
//  CloudKitService.swift
//  oChat
//
//  Created by Vitalii Sosin on 15.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation
import CloudKit

public enum CloudKitRecordTypes: String, Codable {
  case config = "Config"
}

public actor CloudKitService {
  public static let shared = CloudKitService()

  // MARK: - Свойства

  /// Оперативный кэш: для каждого типа храним словарь "ключ-значение" из первой записи CloudKit.
  private var memoryCache: [CloudKitRecordTypes: [String: Any]] = [:]

  /// Текущие задачи на загрузку данных по каждому `recordTypes`.
  /// Если задача уже запущена – повторно её не запускаем, а просто ждём результат.
  private var inProgressTasks: [CloudKitRecordTypes: Task<[String: Any], Error>] = [:]

  /// Срок жизни кэша в `UserDefaults` для `.memes` (пример).
  private let cacheDuration: TimeInterval = 30 * 24 * 60 * 60 // 1 месяц

  private let userDefaults = UserDefaults.standard

  // MARK: - Инициализатор

  private init() {}

  // MARK: - Публичный метод получения значения

  /// Получение значения по ключу `keyName` в первой записи CloudKit для указанного типа `recordTypes`.
  public func getConfigurationValue<T: Codable>(
    from keyName: String,
    recordTypes: CloudKitRecordTypes
  ) async throws -> T? {
    // 1) Проверяем, нет ли уже данных в оперативном кэше.
    if let existingDict = memoryCache[recordTypes] {
      return existingDict[keyName] as? T
    }

    // 2) Если данных нет, смотрим, не идёт ли уже загрузка для данного `recordTypes`.
    if let existingTask = inProgressTasks[recordTypes] {
      // Уже есть задача – просто ждём её результата
      let dict = try await existingTask.value
      return dict[keyName] as? T
    } else {
      // Создаём новую задачу на загрузку
      let fetchTask = Task<[String: Any], Error> {
        let dict = try await fetchRecordFields(recordTypes: recordTypes)
        // После удачной загрузки сохраним в кэш
        memoryCache[recordTypes] = dict
        return dict
      }

      // Запоминаем задачу, чтобы повторно не запустить её
      inProgressTasks[recordTypes] = fetchTask

      do {
        let dict = try await fetchTask.value
        // Удаляем задачу из словаря, так как она завершилась
        inProgressTasks[recordTypes] = nil
        return dict[keyName] as? T
      } catch {
        // Если произошла ошибка, то задача считается завершённой
        inProgressTasks[recordTypes] = nil
        throw error
      }
    }
  }

  // MARK: - Пример отдельного метода для .memes (если понадобится)

  /// Загрузка отдельного поля (например, когда важно получить только одно поле или работать с CKAsset).
  private func fetchSingleRecordField<T: Codable>(
    _ type: T.Type,
    from keyName: String,
    recordTypes: CloudKitRecordTypes
  ) async throws -> T? {
    let container = CKContainer(identifier: "iCloud.com.sosinvitalii.oChat")
    let publicDatabase = container.publicCloudDatabase

    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: recordTypes.rawValue, predicate: predicate)

    // Переходим на синтаксис async с помощью continuation
    let (matchResults, _) = try await withCheckedThrowingContinuation { continuation in
      publicDatabase.fetch(withQuery: query,
                           inZoneWith: nil,
                           desiredKeys: nil,
                           resultsLimit: 1) { result in
        continuation.resume(with: result)
      }
    }

    // Извлекаем первую запись
    guard let record = matchResults.compactMap({ _, recordResult -> CKRecord? in
      if case .success(let r) = recordResult { return r }
      return nil
    }).first else {
      return nil
    }

    // Парсим нужное поле
    if let asset = record[keyName] as? CKAsset,
       T.self == Data.self,
       let fileURL = asset.fileURL {
      // Для случая, когда тип – Data, а в CloudKit лежит CKAsset
      return try Data(contentsOf: fileURL) as? T
    } else {
      // Иначе берем напрямую
      return record[keyName] as? T
    }
  }

  // MARK: - Закрытый метод: грузим первую запись, собираем ВСЕ поля в словарь

  /// Загружает одну (первую) запись указанного типа и возвращает все её поля в виде словаря.
  private func fetchRecordFields(
    recordTypes: CloudKitRecordTypes
  ) async throws -> [String: Any] {
    let container = CKContainer(identifier: "iCloud.com.sosinvitalii.oChat")
    let publicDatabase = container.publicCloudDatabase

    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: recordTypes.rawValue, predicate: predicate)

    // Асинхронно запрашиваем записи
    let (matchResults, _) = try await withCheckedThrowingContinuation { continuation in
      publicDatabase.fetch(
        withQuery: query,
        inZoneWith: nil,
        desiredKeys: nil,
        resultsLimit: 1
      ) { result in
        continuation.resume(with: result)
      }
    }

    // Извлекаем первую запись
    guard let record = matchResults.compactMap({ _, recordResult -> CKRecord? in
      if case .success(let r) = recordResult { return r }
      return nil
    }).first else {
      // Если записей нет, вернём пустой словарь
      return [:]
    }

    // Собираем все поля в словарь
    var recordValues: [String: Any] = [:]
    for fieldKey in record.allKeys() {
      if let asset = record[fieldKey] as? CKAsset,
         let fileURL = asset.fileURL,
         let data = try? Data(contentsOf: fileURL) {
        recordValues[fieldKey] = data
      } else {
        recordValues[fieldKey] = record[fieldKey]
      }
    }

    return recordValues
  }
}
