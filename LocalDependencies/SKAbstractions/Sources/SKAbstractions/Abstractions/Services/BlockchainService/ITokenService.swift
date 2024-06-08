//
//  ITokenService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation

/// Протокол, определяющий функционал для сервиса управления токенами.
public protocol ITokenService {
  
  /// Получить значения для графиков по заданному токену.
  /// - Parameters:
  ///   - token: Модель токена.
  ///   - timeRange: Временной диапазон для данных.
  ///   - completion: Замыкание, вызываемое при завершении запроса, возвращает массив значений графика или ошибку.
  func getValueForChart(
    token: TokenModel,
    timeRange: TimeRangeChart,
    completion: ((Result<[TokenChartValue], SKAbstractions.NetworkError>) -> Void)?
  )
  
  /// Получить цены на токены.
  /// - Parameters:
  ///   - tokens: Список моделей токенов.
  ///   - currency: Модель валюты, в которой выражены цены.
  ///   - completion: Замыкание, вызываемое при завершении запроса, возвращает обновлённый список токенов или ошибку.
  func getPricesForTokens(
    tokens: [TokenModel],
    currency: CurrencyModel,
    completion: ((Result<[TokenModel], SKAbstractions.NetworkError>) -> Void)?
  )
  
  /// Искать токены по имени или символу.
  /// - Parameters:
  ///   - chain: Тип сети токена, необязательный параметр.
  ///   - text: Текст запроса для поиска.
  ///   - limit: Лимит количества возвращаемых результатов.
  ///   - completion: Замыкание, вызываемое при завершении запроса, возвращает список токенов или ошибку.
  func searchTokensByNameOrSymbol(
    chain: TokenNetworkType?,
    text: String,
    limit: Int,
    completion: ((Result<[TokenModel], SKAbstractions.NetworkError>) -> Void)?
  )
}
