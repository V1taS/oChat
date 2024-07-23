//
//  IDataMappingService.swift
//
//
//  Created by Vitalii Sosin on 26.02.2024.
//

import Foundation

/// Сервис для работы с маппингом
public protocol IDataMappingService {
  /// Преобразует модель в данные
  /// - Parameter model: Модель для преобразования.
  /// - Returns: Возвращает `Data` представление модели.
  func encodeModel<T: Encodable>(_ model: T) async throws -> Data?
  
  /// Преобразует данные обратно в модель
  /// - Parameters:
  ///   - type: Тип модели, в которую нужно преобразовать данные.
  ///   - data: Данные для преобразования.
  /// - Returns: Возвращает экземпляр модели, полученный из данных.
  func decodeModel<T: Decodable>(
    _ type: T.Type,
    from data: Data
  ) async throws -> T?
}
