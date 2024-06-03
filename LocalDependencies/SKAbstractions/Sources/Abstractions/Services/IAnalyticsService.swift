//
//  IAnalyticsService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 10.05.2024.
//

import Foundation

/// Протокол `IAnalyticsService` определяет интерфейс для сервиса аналитики.
public protocol IAnalyticsService {
  /// Функция для отслеживания событий.
  ///
  /// - Parameters:
  ///   - event: Название события, которое нужно отслеживать.
  ///   - parameters: Параметры события в виде словаря, где ключ - это строка, а значение может быть любого типа.
  func trackEvent(_ event: String, parameters: [String: Any])
  
  /// Логирует информационное сообщение.
  /// - Parameter message: Сообщение для логирования.
  func log(_ message: String)
  
  /// Логирует ошибку.
  /// - Parameters:
  ///   - error: Строковое описание ошибки.
  ///   - file: Имя файла, в котором произошла ошибка.
  ///   - function: Функция, в которой произошла ошибка.
  ///   - line: Номер строки, на которой произошла ошибка.
  func error(_ error: String, file: String, function: String, line: Int)
  
  /// Логирует ошибку типа `Error`.
  /// - Parameters:
  ///   - error: Ошибка типа `Error`.
  ///   - file: Имя файла, в котором произошла ошибка.
  ///   - function: Функция, в которой произошла ошибка.
  ///   - line: Номер строки, на которой произошла ошибка.
  func error(_ error: Error, file: String, function: String, line: Int)
  
  /// Возвращает URL файла со всеми логами (allLogs.txt).
  func getAllLogs() -> URL?
  
  /// Возвращает URL файла с логами ошибок (errorLogs.txt).
  func getErrorLogs() -> URL?
  
  /// Удаляет все логи.
  func clearAllLogs()
}
