//
//  TokenNetworkType.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 23.04.2024.
//

import Foundation
import UIKit

public enum TokenNetworkType: Int, CaseIterable {
  /// Эфириум ERC-20
  case ethereum = 1
  /// Arbitrum
  case arbitrum = 42161
  /// Aurora
  case aurora = 1313161554
  /// Аваланч AVAX
  case avalanche = 43114
  /// Base
  case base = 8453
  /// Binance Smart Chain BEP-20
  case binance = 56
  /// ZkSync
  case zksync = 324
  /// Fantom
  case fantom = 250
  /// Gnosis
  case gnosis = 100
  /// Klaytn
  case klaytn = 8217
  /// Optimism
  case optimism = 10
  /// Polygon
  case polygon = 137
}

// MARK: - Имя сети и тип токена

extension TokenNetworkType {
  public var details: (name: String, ticker: String, tokenType: String) {
    switch self {
    case .ethereum:
      return ("Ethereum", "ETH", "ERC-20")
    case .arbitrum:
      return ("Arbitrum", "ARB", "ERC-20")
    case .aurora:
      return ("Aurora", "AURORA", "ERC-20")
    case .avalanche:
      return ("Avalanche", "AVAX", "AVAX")
    case .base:
      return ("Base", "BASE", "ERC-20")
    case .binance:
      return ("Binance Smart Chain", "BNB", "BEP-20")
    case .zksync:
      return ("zkSync", "ZKSYNC", "ERC-20")
    case .fantom:
      return ("Fantom", "FTM", "ERC-20")
    case .gnosis:
      return ("Gnosis", "GNO", "ERC-20")
    case .klaytn:
      return ("Klaytn", "KLAY", "KIP-7")
    case .optimism:
      return ("Optimism", "OP", "ERC-20")
    case .polygon:
      return ("Polygon", "MATIC", "ERC-20")
    }
  }
  
  /// Изображение токена
  public var imageNetworkURL: URL? {
    let urlString = "\(Secrets.tokenBaseUrlString)\(details.ticker.lowercased()).png"
    guard let url = URL(string: urlString) else {
      return nil
    }
    return url
  }
}

// MARK: - IdentifiableAndCodable

extension TokenNetworkType: IdentifiableAndCodable {
  public var id: Int {
    return self.rawValue
  }
}
