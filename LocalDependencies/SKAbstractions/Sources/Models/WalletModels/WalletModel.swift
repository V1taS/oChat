//
//  WalletModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SwiftUI

public struct WalletModel {
  
  // MARK: - Public properties
  
  /// Уникальный идентификатор кошелька.
  public let id: UUID
  
  /// Название кошелька.
  public var name: String?
  
  /// Список токенов в кошельке.
  public let tokens: [TokenModel]
  
  /// Признак того, является ли кошелек основным.
  public var isPrimary: Bool
  
  /// Фраза восстановления кошелька.
  public let seedPhrase: String
  
  /// Публичный ключ кошелька.
  public let publicKey: String
  
  /// Приватный ключ кошелька.
  public let privateKey: String
  
  /// Дата и время создания кошелька.
  public let createdAt: Date
  
  /// Список транзакций кошелька.
  public let transactions: [TransactionModel]
  
  /// Статус активности кошелька.
  public let isActive: Bool
  
  /// Тип кошелька
  public var walletType: WalletType
  
  // MARK: - Initializer
  
  /// Инициализирует экземпляр `WalletModel`.
  /// - Parameters:
  ///   - id: Уникальный идентификатор кошелька.
  ///   - name: Название кошелька.
  ///   - tokens: Список токенов в кошельке.
  ///   - isPrimary: Признак того, является ли кошелек основным.
  ///   - seedPhrase: Фраза восстановления кошелька.
  ///   - publicKey: Публичный ключ кошелька.
  ///   - privateKey: Приватный ключ кошелька.
  ///   - createdAt: Дата и время создания кошелька.
  ///   - transactions: Список транзакций кошелька.
  ///   - isActive: Статус активности кошелька.
  ///   - walletType: Тип кошелька
  public init(
    id: UUID,
    name: String?,
    tokens: [TokenModel],
    isPrimary: Bool,
    seedPhrase: String,
    publicKey: String,
    privateKey: String,
    createdAt: Date,
    transactions: [TransactionModel],
    isActive: Bool,
    walletType: WalletType
  ) {
    self.id = id
    self.name = name
    self.tokens = tokens
    self.isPrimary = isPrimary
    self.seedPhrase = seedPhrase
    self.publicKey = publicKey
    self.privateKey = privateKey
    self.createdAt = createdAt
    self.transactions = transactions
    self.isActive = isActive
    self.walletType = walletType
  }
}

// MARK: - Extension

extension WalletModel {
  /// Общий баланс в выбранной валюте
  public var totalTokenBalanceInCurrency: Decimal {
    tokens.reduce(0, { sum, token in
      sum + token.costInCurrency
    })
  }
}

// MARK: - WalletType

extension WalletModel {
  public enum WalletType: IdentifiableAndCodable {
    /// Стандартный кошелек
    case seedPhrase12
    /// Нерушимый кошелек
    case seedPhrase24
    /// Высокотехнологичный кошелек с Image ID
    case highTechImageID(_ image: Data?)
    
    /// Image ID
    public var imageID: Data? {
      switch self {
      case let .highTechImageID(imageID):
        return imageID
      default:
        return nil
      }
    }
    
    /// Кошелек с Image ID
    public var isHighTechImageID: Bool {
      switch self {
      case .highTechImageID:
        return true
      default:
        return false
      }
    }
  }
}

// MARK: - Mock Extension

extension WalletModel {
  /// Возвращает тестовый экземпляр `WalletModel`.
  public static var mock: WalletModel {
    return WalletModel(
      id: UUID(),
      name: "Test Wallet",
      tokens: [],
      isPrimary: true,
      seedPhrase: "test test test test test test test test test test test test",
      publicKey: "xpub6CUGRUonZSQ4TWtTMmzXdrXDtyPWKiZrFH1gBtsSaVZnyEjbRwLuvCJN66B8i3Ni8Qo44aKx6Ff53745LrbDxPYK2MR1GWoEqm14HfctDXY",
      privateKey: "xprv9s21ZrQH143K3uM4EqX2LwmSicNX4f5dF2Yn4aB4eg",
      createdAt: Date(),
      transactions: [],
      isActive: true,
      walletType: .seedPhrase12
    )
  }
}

// MARK: - IdentifiableAndCodable

extension WalletModel: IdentifiableAndCodable {}
