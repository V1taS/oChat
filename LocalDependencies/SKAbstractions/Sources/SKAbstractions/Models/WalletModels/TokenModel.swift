//
//  TokenModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 23.04.2024.
//

import SwiftUI

public struct TokenModel {
  
  // MARK: - Public propertie
  
  /// Уникальный номер
  public let id: UUID
  
  /// Название токена
  /// - Пример: "SHIBA INU"
  public let name: String
  
  /// Символ токена, используемый в торговле, например: "SHIB"
  public let ticker: String
  
  /// Адрес токена
  /// - Пример: "0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce"
  public let address: String
  
  /// Десятичные знаки токена
  /// - Пример: 18
  public let decimals: Int
  
  /// Поддерживает ли токен EIP2612
  /// - Пример: false
  public let eip2612: Bool?
  
  /// Является ли токен с платой за перевод
  public let isFeeOnTransfer: Bool?
  
  /// Текущая сеть токена, например Ethereum Mainnet или Binance Smart Chain.
  public let network: TokenNetworkType
  
  /// Список всех сетей, в которых доступен данный токен.
  public let availableNetworks: [TokenNetworkType]
  
  /// Количество токенов на балансе.
  public let tokenAmount: Decimal
  
  /// Валюта, в которой выражен баланс фиатного значения, например "$".
  public var currency: CurrencyModel?
  
  /// Статус активности токена, где true означает, что токен активен.
  public let isActive: Bool
  
  // MARK: - Private properties
  
  /// URI логотипа токена
  /// - Пример: "https://tokens.1inch.io/0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce.png"
  private let logoURI: String?
  
  // MARK: - Initializer
  
  /// Инициализирует модель токена.
  /// - Parameters:
  ///   - name: Название токена.
  ///   - ticker: Символ токена.
  ///   - address: Адрес токена
  ///   - decimals: Десятичные знаки токена. Пример: 18
  ///   - eip2612: Поддерживает ли токен EIP2612
  ///   - isFeeOnTransfer: Является ли токен с платой за перевод
  ///   - network: Текущая сеть токена.
  ///   - availableNetworks: Список доступных сетей для токена.
  ///   - tokenAmount: Количество токенов на балансе.
  ///   - currency: Валюта, в которой выражен баланс фиатного значения, например "$".
  ///   - isActive: Статус активности токена.
  ///   - logoURI: URI логотипа токена
  public init(
    name: String,
    ticker: String,
    address: String,
    decimals: Int,
    eip2612: Bool? = false,
    isFeeOnTransfer: Bool?,
    network: TokenNetworkType,
    availableNetworks: [TokenNetworkType] = [],
    tokenAmount: Decimal = .zero,
    currency: CurrencyModel? = nil,
    isActive: Bool = false,
    logoURI: String? = nil
  ) {
    self.id = UUID()
    self.name = name
    self.ticker = ticker
    self.address = address
    self.decimals = decimals
    self.eip2612 = eip2612
    self.network = network
    self.availableNetworks = availableNetworks
    self.isFeeOnTransfer = isFeeOnTransfer
    self.tokenAmount = tokenAmount
    self.currency = currency
    self.isActive = isActive
    self.logoURI = logoURI
  }
}

// MARK: - Extension

extension TokenModel {
  /// Стоимость в валюте
  public var costInCurrency: Decimal {
    tokenAmount * (currency?.pricePerToken ?? .zero)
  }
}

// MARK: - Mock

extension TokenModel {
  public static var ethereumMock: TokenModel {
    .init(
      name: "Ethereum",
      ticker: "ETH",
      address: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
      decimals: 18,
      eip2612: true,
      isFeeOnTransfer: false,
      network: .ethereum,
      availableNetworks: [.ethereum, .binance],
      tokenAmount: 10,
      currency: .init(type: .usd, pricePerToken: .zero),
      isActive: true,
      logoURI: nil
    )
  }
  
  public static var binanceMock: TokenModel {
    .init(
      name: "Binance Coin",
      ticker: "BNB",
      address: "0xB8c77482e45F1F44dE1745F52C74426C631bDD52",
      decimals: 18,
      eip2612: false,
      isFeeOnTransfer: true,
      network: .binance,
      availableNetworks: [.binance, .ethereum],
      tokenAmount: 25,
      currency: .init(type: .usd, pricePerToken: .zero),
      isActive: true,
      logoURI: nil
    )
  }
  
  public static var cardanoMock: TokenModel {
    .init(
      name: "Cardano",
      ticker: "ADA",
      address: "0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47", // Этот адрес для ADA на Binance Smart Chain (BEP-20)
      decimals: 6,
      eip2612: nil,
      isFeeOnTransfer: false,
      network: .arbitrum,
      availableNetworks: [.arbitrum],
      tokenAmount: 300,
      currency: .init(type: .usd, pricePerToken: .zero),
      isActive: false,
      logoURI: nil
    )
  }
  
  public static var solanaMock: TokenModel {
    .init(
      name: "Solana",
      ticker: "SOL",
      address: "0x0762f2Ece52f7e440d3d99C8065eFad6ab4b73F8", // Этот адрес для моста Solana на Ethereum
      decimals: 9,
      eip2612: nil,
      isFeeOnTransfer: false,
      network: .fantom,
      availableNetworks: [.aurora],
      tokenAmount: 50,
      currency: .init(type: .usd, pricePerToken: .zero),
      isActive: true,
      logoURI: nil
    )
  }
  
  // MARK: - Array of All Mocks
  
  public static var allMocks: [TokenModel] {
    [ethereumMock, binanceMock, cardanoMock, solanaMock]
  }
}

// MARK: - Image token URL

extension TokenModel {
  /// Изображение токена
  public var imageTokenURL: URL? {
    let urlSafeKeeperString = "\(Secrets.tokenBaseUrlString)\(ticker.lowercased()).png"
    let urlSafeKeeper = URL(string: urlSafeKeeperString)
    let url1inch = URL(string: logoURI ?? "")
    return url1inch ?? urlSafeKeeper
  }
}

// MARK: - IdentifiableAndCodable

extension TokenModel: IdentifiableAndCodable {}
