//
//  ISecureDataManagerService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 10.05.2024.
//

import Foundation

/// Протокол для управления безопасным хранением данных.
public protocol ISecureDataManagerService {
  /// Возвращает строку, сохранённую по указанному ключу.
  /// - Parameter key: Ключ для поиска строки.
  func getString(for key: String) -> String?
  
  /// Возвращает данные, сохранённые по указанному ключу.
  /// - Parameter key: Ключ для поиска данных.
  func getData(for key: String) -> Data?
  
  /// Возвращает модель, декодированную из данных, сохранённых по указанному ключу.
  /// - Parameter key: Ключ для поиска и декодирования данных.
  func getModel<T: Decodable>(for key: String) -> T?
  
  /// Сохраняет строку по указанному ключу.
  /// - Parameters:
  ///   - string: Строка для сохранения.
  ///   - key: Ключ, по которому будет сохранена строка.
  /// - Returns: Возвращает `true`, если сохранение прошло успешно.
  @discardableResult
  func saveString(_ string: String, key: String) -> Bool
  
  /// Сохраняет данные по указанному ключу.
  /// - Parameters:
  ///   - data: Данные для сохранения.
  ///   - key: Ключ, по которому будут сохранены данные.
  /// - Returns: Возвращает `true`, если сохранение прошло успешно.
  @discardableResult
  func saveData(_ data: Data, key: String) -> Bool
  
  /// Сохраняет модель по указанному ключу.
  /// - Parameters:
  ///   - model: Модель для сохранения.
  ///   - key: Ключ, по которому будет сохранена модель.
  /// - Returns: Возвращает `true`, если сохранение прошло успешно.
  @discardableResult
  func saveModel<T: Encodable>(_ model: T, for key: String) -> Bool
  
  /// Удаляет данные по указанному ключу.
  /// - Parameter key: Ключ для удаления данных.
  /// - Returns: Возвращает `true`, если удаление прошло успешно.
  @discardableResult
  func deleteData(for key: String) -> Bool
  
  /// Удаляет все данные
  @discardableResult
  func deleteAllData() -> Bool
}
