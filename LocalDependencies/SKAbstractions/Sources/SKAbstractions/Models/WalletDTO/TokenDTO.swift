//
//  TokenDTO.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 30.05.2024.
//

import Foundation

/// Модель для представления токена
public struct TokenDTO: Codable {
  /// Идентификатор цепи
  /// - Пример: 1
  let chainId: Int
  /// Символ токена
  /// - Пример: "SHIB"
  let symbol: String
  /// Название токена
  /// - Пример: "SHIBA INU"
  let name: String
  /// Адрес токена
  /// - Пример: "0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce"
  let address: String
  /// Десятичные знаки токена
  /// - Пример: 18
  let decimals: Int
  /// URI логотипа токена
  /// - Пример: "https://tokens.1inch.io/0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce.png"
  let logoURI: String?
  /// Рейтинг токена
  /// - Пример: 1018
  let rating: Int?
  /// Поддерживает ли токен EIP2612
  /// - Пример: false
  let eip2612: Bool?
  /// Является ли токен с платой за перевод
  let isFoT: Bool?
  /// Теги токена
  /// - Пример: [Token.Tag(provider: "1inch", value: "tokens")]
  let tags: [Tag]?
  /// Провайдеры токена
  /// - Пример: ["1inch", "CoinGecko", "Coinmarketcap"]
  let providers: [String]?
}

// MARK: - Tag

extension TokenDTO {
  /// Модель для представления тега
  struct Tag: Codable {
    /// Провайдер тега
    /// - Пример: "1inch"
    let provider: String
    /// Значение тега
    /// - Пример: "tokens"
    let value: String
  }
}

// MARK: - Mock token

extension TokenDTO {
  public func mapTo() -> TokenModel {
    TokenModel(
      name: name,
      ticker: symbol,
      address: address,
      decimals: decimals,
      eip2612: eip2612,
      isFeeOnTransfer: isFoT,
      network: TokenNetworkType(rawValue: chainId) ?? .ethereum,
      availableNetworks: [],
      tokenAmount: .zero,
      isActive: false,
      logoURI: logoURI
    )
  }
}

// MARK: - Mock token

extension TokenDTO {
  /// Пример использования
  public static let mockToken = Self(
    chainId: 1,
    symbol: "SHIB",
    name: "SHIBA INU",
    address: "0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce",
    decimals: 18,
    logoURI: "https://tokens.1inch.io/0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce.png",
    rating: 1018,
    eip2612: false,
    isFoT: true,
    tags: [
      TokenDTO.Tag(provider: "1inch", value: "tokens")
    ],
    providers: [
      "1inch",
      "CoinGecko",
      "Coinmarketcap",
      "Curve Token List",
      "Furucombo",
      "Gemini Token List",
      "Kleros Tokens",
      "Uniswap Labs Default",
      "Zerion"
    ]
  )
}
