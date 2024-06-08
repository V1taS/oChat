//
//  TransactionModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 07.05.2024.
//

import SwiftUI

public struct TransactionModel {
  
  // MARK: - Public propertie
  
  /// Уникальный номер
  public let id: UUID
  
  /// Токен по которому происходит транзакция
  public let token: TokenModel
  
  /// Сумма транзакции
  public let amount: Decimal
  
  /// Дата транзакции
  public let date: Date
  
  /// Статус транзакции, указывающий на её тип.
  public let transactionType: TransactionType
  
  /// Адрес получателя
  public let addressRecipient: String
  
  /// Сумма комиссии
  public let commissionAmount: Decimal
  
  /// Ссылка на транзакцию
  public let transactionWebLink: String
  
  /// Текущая сеть токена, например Ethereum Mainnet или Binance Smart Chain.
  public let network: TokenNetworkType
  
  /// Комментариц к транзакции
  public let comment: String?
  
  // MARK: - Initializer
  
  /// Инициализирует новый экземпляр `TransactionModel` с заданными параметрами.
  /// - Parameters:
  ///   - id: Уникальный идентификатор транзакции.
  ///   - token: Токен по которому происходит транзакция
  ///   - amount: Сумма транзакции
  ///   - date: Дата проведения транзакции.
  ///   - transactionType: Тип транзакции.
  ///   - addressRecipient: Адрес получателя транзакции.
  ///   - commissionAmount: Размер комиссии за транзакцию.
  ///   - transactionWebLink: Ссылка на подробности транзакции.
  ///   - network: Сеть, в которой производится транзакция.
  ///   - comment: Комментариц к транзакции
  public init(
    id: UUID,
    token: TokenModel,
    amount: Decimal,
    date: Date,
    transactionType: TransactionType,
    addressRecipient: String,
    commissionAmount: Decimal,
    transactionWebLink: String,
    network: TokenNetworkType,
    comment: String?
  ) {
    self.id = id
    self.token = token
    self.amount = amount
    self.date = date
    self.transactionType = transactionType
    self.addressRecipient = addressRecipient
    self.commissionAmount = commissionAmount
    self.transactionWebLink = transactionWebLink
    self.network = network
    self.comment = comment
  }
}

// MARK: - Extension

extension TransactionModel {
  /// Стоимость в валюте
  public var costInCurrency: Decimal {
    amount * (token.currency?.pricePerToken ?? .zero)
  }
  
  /// Сумма комиссии в валюте
  public var commissionInCurrency: Decimal {
    commissionAmount * (token.currency?.pricePerToken ?? .zero)
  }
  
  /// Изображение токена
  public var imageTokenURL: URL? {
    token.imageTokenURL
  }
}

// MARK: - Mocks

extension TransactionModel {
  /// Возвращает мок одной транзакции
  public static var singleMock: TransactionModel {
    TransactionModel(
      id: UUID(),
      token: .cardanoMock,
      amount: 1_000,
      date: Date().addingTimeInterval(-172800), // Позавчера
      transactionType: .sent,
      addressRecipient: "0xabcdef987654321",
      commissionAmount: 0.01,
      transactionWebLink: "https://cardanoscan.io/tx/0xabcdef",
      network: .base,
      comment: nil
    )
  }
  
  /// Возвращает список мок транзакций
  public static var listMock: [TransactionModel] {
    [
      TransactionModel(
        id: UUID(),
        token: .binanceMock,
        amount: 1_000,
        date: Date(),
        transactionType: .received,
        addressRecipient: "0x123456789abcdef",
        commissionAmount: 0.01,
        transactionWebLink: "https://etherscan.io/tx/0xabcdef",
        network: .ethereum,
        comment: nil
      ),
      TransactionModel(
        id: UUID(),
        token: .ethereumMock,
        amount: 1_000,
        date: Date().addingTimeInterval(-86400), // Вчера
        transactionType: .cancelled,
        addressRecipient: "0xbcd123456789ef",
        commissionAmount: 0.05,
        transactionWebLink: "https://bscscan.com/tx/0xbcdef",
        network: .binance,
        comment: nil
      ),
      TransactionModel(
        id: UUID(),
        token: .solanaMock,
        amount: 1_000,
        date: Date().addingTimeInterval(-172800), // Позавчера
        transactionType: .sent,
        addressRecipient: "0xabcdef987654321",
        commissionAmount: 0.01,
        transactionWebLink: "https://cardanoscan.io/tx/0xabcdef",
        network: .polygon,
        comment: nil
      ),
      TransactionModel(
        id: UUID(),
        token: .ethereumMock,
        amount: 1_000,
        date: Date().addingTimeInterval(-259200), // Три дня назад
        transactionType: .declined,
        addressRecipient: "0x123456abcdef",
        commissionAmount: 0.03,
        transactionWebLink: "https://solscan.io/tx/0x123456",
        network: .optimism,
        comment: nil
      ),
      TransactionModel(
        id: UUID(),
        token: .ethereumMock,
        amount: 1_000,
        date: Date().addingTimeInterval(-345600), // Четыре дня назад
        transactionType: .received,
        addressRecipient: "0x987654321abcdef",
        commissionAmount: 0.02,
        transactionWebLink: "https://polkadot.js.org/apps/#/explorer/query/0x987654",
        network: .gnosis,
        comment: nil
      )
    ]
  }
}

// MARK: - IdentifiableAndCodable

extension TransactionModel: IdentifiableAndCodable {}
