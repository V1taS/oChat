//
//  TokenService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation
import WalletCore
import SKFoundation
import SKAbstractions
import SKNetwork

/// Финальный класс для управления токенами.
public final class TokenService: ITokenService {
  
  // MARK: - Private properties
  
  private let networkService: INetworkService = NetworkService()
  
  // MARK: - Init
  
  /// Инициализатор
  public init() {}
  
  // MARK: - Public Methods
  
  public func getValueForChart(
    token: TokenModel,
    timeRange: TimeRangeChart,
    completion: ((Result<[TokenChartValue], SKAbstractions.NetworkError>) -> Void)?
  ) {
    let queryItems = [
      URLQueryItem(name: "addresses", value: token.address),
      URLQueryItem(name: "chain_id", value: "\(token.network.rawValue)"),
      URLQueryItem(name: "timerange", value: "\(timeRange.rawValue)")
    ]
    let urlString = Constants.baseOneInchUrlString + Constants.oneInchValueChartUrlString
    
    networkService.performRequestWith(
      urlString: urlString,
      queryItems: queryItems,
      httpMethod: .get,
      headers: Constants.requestHeaders) { [weak self] result in
        guard let self else {
          return
        }
        switch result {
        case let .success(data):
          if let tokenChartValueDTO = networkService.map(data, to: TokenChartValueDTO.self) {
            let tokenChartValue = tokenChartValueDTO.result.compactMap { $0.mapTo() }
            completion?(.success(tokenChartValue))
          } else {
            completion?(.failure(.mappingError))
          }
        case let .failure(error):
          completion?(.failure(error.mapTo()))
        }
      }
  }
  
  public func getPricesForTokens(
    tokens: [TokenModel],
    currency: CurrencyModel,
    completion: ((Result<[TokenModel], SKAbstractions.NetworkError>) -> Void)?
  ) {
    let addresses = tokens.compactMap({ $0.address }).joined(separator: ",")
    let queryItems = [
      URLQueryItem(name: "currency", value: "\(currency.type.details.id)")
    ]
    let priceUrlString = String(
      format: Constants.oneInchPriceUrlString,
      "\(tokens.first?.network.rawValue ?? 1)",
      "\(addresses)"
    )
    
    let urlString = Constants.baseOneInchUrlString + priceUrlString
    networkService.performRequestWith(
      urlString: urlString,
      queryItems: queryItems,
      httpMethod: .get,
      headers: Constants.requestHeaders) { [weak self] result in
        guard let self else {
          return
        }
        switch result {
        case let .success(data):
          if let prices = networkService.map(data, to: [String: String].self) {
            let updateTokens = updateTokensWithPrices(tokens: tokens, prices: prices)
            completion?(.success(updateTokens))
          } else {
            completion?(.failure(.mappingError))
          }
        case let .failure(error):
          completion?(.failure(error.mapTo()))
        }
      }
  }
  
  public func searchTokensByNameOrSymbol(
    chain: TokenNetworkType?,
    text: String,
    limit: Int,
    completion: ((Result<[TokenModel], SKAbstractions.NetworkError>) -> Void)?
  ) {
    let queryItems = [
      URLQueryItem(name: "query", value: text),
      URLQueryItem(name: "limit", value: "\(limit)"),
      URLQueryItem(name: "ignore_listed", value: "false"),
      URLQueryItem(name: "only_positive_rating", value: "true")
    ]
    
    let searchUrlString = Constants.baseOneInchUrlString + Constants.oneInchSearchUrlString
    let searchWithChainUrlString = Constants.baseOneInchUrlString + String(
      format: Constants.oneInchSearchChainUrlString,
      "\(chain?.rawValue ?? .zero)"
    )
    let urlString = chain == nil ? searchUrlString : searchWithChainUrlString
    
    networkService.performRequestWith(
      urlString: urlString,
      queryItems: queryItems,
      httpMethod: .get,
      headers: Constants.requestHeaders) { [weak self] result in
        guard let self else {
          return
        }
        switch result {
        case let .success(data):
          if let tokensDTO = networkService.map(data, to: [TokenDTO].self) {
            let tokens = tokensDTO.compactMap { $0.mapTo() }
            completion?(.success(tokens))
          } else {
            completion?(.failure(.mappingError))
          }
        case let .failure(error):
          completion?(.failure(error.mapTo()))
        }
      }
  }
}

// MARK: - Private

private extension TokenService {
  func updateTokensWithPrices(
    tokens: [TokenModel],
    prices: [String: String]
  ) -> [TokenModel] {
    return tokens.compactMap { token in
      var updatedToken = token
      if let price = prices[token.address],
         let tokensPrices = Decimal(string: price) {
        updatedToken.currency?.pricePerToken = tokensPrices
      }
      return updatedToken
    }
  }
}

// MARK: - Mapping

extension SKNetwork.NetworkError {
  func mapTo() -> SKAbstractions.NetworkError {
    switch self {
    case .noInternetConnection:
      return .noInternetConnection
    case .invalidURLRequest:
      return .invalidURLRequest
    case let .unacceptedHTTPStatus(code, localizedDescription):
      return .unacceptedHTTPStatus(code: code, localizedDescription: localizedDescription)
    case .unexpectedServerResponse:
      return .unexpectedServerResponse
    case .mappingError:
      return .mappingError
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let baseOneInchUrlString = "https://api.1inch.dev/"
  static let oneInchSearchUrlString = "token/v1.2/search"
  static let oneInchSearchChainUrlString = "token/v1.2/%@/search"
  static let oneInchValueChartUrlString = "portfolio/portfolio/v4/general/value_chart"
  
  static let oneInchPriceUrlString = "price/v1.1/%@/%@"
  static let authorizationOneInch = (key: "Authorization", value: "Bearer \(Secrets.oneInchKeys)")
  static let requestHeaders: [HeadersType] = [
    HeadersType.acceptJson,
    HeadersType.contentTypeJson,
    HeadersType.additionalHeaders(
      set: [
        (Constants.authorizationOneInch.key,
         Constants.authorizationOneInch.value)
      ]
    )
  ]
}
