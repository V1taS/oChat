//
//  WalletCardView+Model.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SwiftUI
import SKStyle

// MARK: - Model

extension WalletCardView {
  /// Модель данных для представления карточки кошелька.
  public struct Model {
    /// Название кошелька.
    public let walletName: String
    /// Адрес кошелька.
    public let walletAddress: String
    /// Общая сумма в кошельке.
    public let totalAmount: String
    /// Валюта суммы.
    public let currency: String
    /// Стиль отображения карточки кошелька.
    public let walletStyle: WalletCardView.Style
    
    /// Создает новую модель карточки кошелька.
    /// - Parameters:
    ///   - walletName: Название кошелька.
    ///   - walletAddress: Адрес кошелька.
    ///   - totalAmount: Общая сумма в кошельке.
    ///   - currency: Валюта суммы.
    ///   - walletStyle: Стиль отображения карточки.
    public init(
      walletName: String,
      walletAddress: String,
      totalAmount: String,
      currency: String,
      walletStyle: WalletCardView.Style
    ) {
      self.walletName = walletName
      self.walletAddress = walletAddress
      self.totalAmount = totalAmount
      self.currency = currency
      self.walletStyle = walletStyle
    }
  }
}

// MARK: - Style

extension WalletCardView {
  /// Перечисление стилей для карточки кошелька.
  public enum Style {
    /// Стандартный стиль карточки.
    case standard
    
    /// Цвет текста для названия кошелька.
    var walletNameColor: Color {
      switch self {
      case .standard:
        return SKStyleAsset.constantGhost.swiftUIColor
      }
    }
    
    /// Цвет текста для адреса кошелька.
    var walletAddressColor: Color {
      switch self {
      case .standard:
        return SKStyleAsset.constantSlate.swiftUIColor
      }
    }
    
    /// Цвет текста для общей суммы.
    var walletTotalAmountColor: Color {
      switch self {
      case .standard:
        return SKStyleAsset.constantGhost.swiftUIColor
      }
    }
    
    /// Цвета градиента карты.
    var cardGradientColors: [Color] {
      switch self {
      case .standard:
        return [
          SKStyleAsset.constantAzure.swiftUIColor,
          SKStyleAsset.constantAzure.swiftUIColor
        ]
      }
    }
  }
}
