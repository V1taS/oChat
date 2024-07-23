//
//  ICloudKitService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 12.05.2024.
//

import Foundation

/// Протокол для работы с CloudKit для получения конфигурационных данных.
public protocol ICloudKitService {
  /// Получает значение конфигурации по ключу.
  /// - Parameters:
  ///   - keyName: Имя ключа, по которому нужно получить значение.
  ///   - return: Ррезультат операции. Возвращает значение типа `T?`.
  func getConfigurationValue<T>(from keyName: String) async throws -> T?
}
