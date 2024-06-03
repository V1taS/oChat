//
//  TokenChartValue.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation

// MARK: - TokenChartValue

/// Структура для хранения значения токена в долларах США и соответствующей даты.
public struct TokenChartValue {
  /// Дата, для которой указано значение токена.
  public let date: Date
  /// Значение токена в долларах США.
  public let valueUSD: Double
  
  /// Инициализатор для создания нового экземпляра `TokenChartValue`.
  /// - Parameters:
  ///   - date: Дата, для которой указано значение токена.
  ///   - valueUSD: Значение токена в долларах США.
  public init(date: Date, valueUSD: Double) {
    self.date = date
    self.valueUSD = valueUSD
  }
}
