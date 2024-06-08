//
//  TokenChartValueDTO.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation

// MARK: - TokenValueDTO

public struct TokenChartValueDTO: Codable {
  /// Массив данных
  public let result: [TokenDayValue]
  
  /// Перечисление для кодирования и декодирования ключей в модели.
  enum CodingKeys: String, CodingKey {
    case result
  }
}

// MARK: - TokenDayValue

extension TokenChartValueDTO {
  /// Структура для хранения данных о стоимости токена в конкретный день.
  public struct TokenDayValue: Codable {
    /// Временная метка дня, представленная в виде целочисленного значения.
    public let timestamp: Int
    /// Стоимость токена в долларах США.
    public let valueUSD: Double
    
    /// Перечисление для кодирования и декодирования ключей в модели.
    enum CodingKeys: String, CodingKey {
      /// Временная метка.
      case timestamp
      /// Стоимость токена в долларах США.
      case valueUSD = "value_usd"
    }
  }
}

// MARK: - TokenDayValue

extension TokenChartValueDTO.TokenDayValue {
  public func mapTo() -> TokenChartValue {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    return TokenChartValue(date: date, valueUSD: valueUSD)
  }
}
