//
//  CryptoConverterView+Model.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 18.03.2024.
//

import SwiftUI
import SKStyle

// MARK: - Model

@available(iOS 16.0, *)
extension CryptoConverterView {
  public struct Model: Identifiable, Equatable {
    // MARK: - Public properties
    public let id: UUID
    public let text: Binding<String>
    public let fieldType: FieldType
    public let placeholder: String
    public let leftSide: LeftSide
    public let rightSide: RightSide?
    public let onTextChange: ((_ newValue: String) -> Void)?
    public let onTextFieldFocusedChange: ((_ isFocused: Bool, _ text: String) -> Void)?
    
    // MARK: - Initialization
    
    /// Инициализатор для создания модельки для виджета
    /// - Parameters:
    ///   - text: Текст в поле
    ///   - fieldType: Тип поля
    ///   - placeholder: Плейсхолдер
    ///   - leftSide: Левая сторона криптоконвертера
    ///   - rightSide: Правая сторона криптоконвертера
    ///   - onTextChange: Текст был изменен
    ///   - onTextFieldFocusedChange: Фокус на клавиатуре был изменен
    public init(
      text: Binding<String>,
      fieldType: CryptoConverterView.FieldType,
      placeholder: String,
      leftSide: CryptoConverterView.LeftSide,
      rightSide: CryptoConverterView.RightSide?,
      onTextChange: ((_ newValue: String) -> Void)? = nil,
      onTextFieldFocusedChange: ((_ isFocused: Bool, _ text: String) -> Void)? = nil
    ) {
      self.id = UUID()
      self.text = text
      self.fieldType = fieldType
      self.placeholder = placeholder
      self.leftSide = leftSide
      self.rightSide = rightSide
      self.onTextChange = onTextChange
      self.onTextFieldFocusedChange = onTextFieldFocusedChange
    }
  }
}

// MARK: - LeftSide

@available(iOS 16.0, *)
extension CryptoConverterView {
  public struct LeftSide: Equatable {
    // MARK: - Public properties
    public let title: String
    public let shortFormCryptoName: String?
    public let longFormCryptoName: String?
    public let imageCrypto: URL?
    public let isSelectable: Bool
    public let action: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Инициализатор для создания модельки
    /// - Parameters:
    ///   - title: Заголовок, например: ``Отправить``
    ///   - shortFormCryptoName: Короткое название, например: ``ETH``
    ///   - longFormCryptoName: Полное название, например: ``Ethereum``
    ///   - isSelectable: Можно ли нажать на кнопку
    ///   - action: Нажатие на иконку с коротким названием
    public init(
      title: String,
      shortFormCryptoName: String? = nil,
      longFormCryptoName: String? = nil,
      imageCrypto: URL? = nil,
      isSelectable: Bool = true,
      action: (() -> Void)? = nil
    ) {
      self.title = title
      self.shortFormCryptoName = shortFormCryptoName
      self.longFormCryptoName = longFormCryptoName
      self.imageCrypto = imageCrypto
      self.isSelectable = isSelectable
      self.action = action
    }
  }
}

// MARK: - RightSide

@available(iOS 16.0, *)
extension CryptoConverterView {
  public struct RightSide: Equatable {
    // MARK: - Public properties
    public let totalAmount: TotalAmount?
    public let fieldWithAmount: FieldWithAmount
    public let currencySwitcher: CurrencySwitcher?
    
    // MARK: - Initialization
    
    /// Инициализатор для создания модельки
    /// - Parameters:
    ///   - totalAmount: Максимальная сумма которую можно применить.
    ///   - fieldWithAmount: Поле для ввода
    ///   - currencySwitcher: Показываем поле в какой валюте и можем сменить ее
    public init(
      totalAmount: TotalAmount?,
      fieldWithAmount: FieldWithAmount,
      currencySwitcher: CurrencySwitcher?
    ) {
      self.totalAmount = totalAmount
      self.fieldWithAmount = fieldWithAmount
      self.currencySwitcher = currencySwitcher
    }
  }
}

// MARK: - TotalAmount

@available(iOS 16.0, *)
extension CryptoConverterView {
  public struct TotalAmount: Equatable {
    // MARK: - Public properties
    public let totalCryptoTitle: String
    public let totalCrypto: String
    public let applyMaximumAmount: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Инициализатор для создания модельки
    /// - Parameters:
    ///   - totalCryptoTitle: Заголовок
    ///    - totalCrypto: Максимальная сумма которую можно применить.
    ///   - applyMaximumAmount: При нажатии на текст, применяется максимальная сумма
    public init(
      totalCryptoTitle: String,
      totalCrypto: String,
      applyMaximumAmount: (() -> Void)?
    ) {
      self.totalCryptoTitle = totalCryptoTitle
      self.totalCrypto = totalCrypto
      self.applyMaximumAmount = applyMaximumAmount
    }
  }
}

// MARK: - FieldWithAmount

@available(iOS 16.0, *)
extension CryptoConverterView {
  public struct FieldWithAmount: Equatable {
    // MARK: - Public properties
    public let currency: String?
    
    // MARK: - Initialization
    
    /// Инициализатор для создания модельки
    /// - Parameters:
    ///   - currency: Валюта
    public init(
      currency: String?
    ) {
      self.currency = currency
    }
  }
}

// MARK: - CurrencySwitcher

@available(iOS 16.0, *)
extension CryptoConverterView {
  public struct CurrencySwitcher: Equatable {
    // MARK: - Public properties
    public let amountInCurrency: String
    public let switchCurrencyAction: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Инициализатор для создания модельки
    /// - Parameters:
    ///   - amountInCurrency: Показывает сумму в какой то валюте
    ///   - switchCurrencyAction: Переключить валюту
    public init(
      amountInCurrency: String,
      switchCurrencyAction: (() -> Void)?
    ) {
      self.amountInCurrency = amountInCurrency
      self.switchCurrencyAction = switchCurrencyAction
    }
  }
}

// MARK: - Equatable CurrencySwitcher

@available(iOS 16.0, *)
extension CryptoConverterView.CurrencySwitcher {
  public static func == (
    lhs: CryptoConverterView.CurrencySwitcher,
    rhs: CryptoConverterView.CurrencySwitcher
  ) -> Bool {
    return lhs.amountInCurrency == rhs.amountInCurrency
  }
}

// MARK: - Equatable CurrencySwitcher

@available(iOS 16.0, *)
extension CryptoConverterView.TotalAmount {
  public static func == (
    lhs: CryptoConverterView.TotalAmount,
    rhs: CryptoConverterView.TotalAmount
  ) -> Bool {
    return lhs.totalCrypto == rhs.totalCrypto
  }
}

// MARK: - Equatable RightSide

@available(iOS 16.0, *)
extension CryptoConverterView.RightSide {
  public static func == (
    lhs: CryptoConverterView.RightSide,
    rhs: CryptoConverterView.RightSide
  ) -> Bool {
    let areTotalAmountsEqual = lhs.totalAmount == rhs.totalAmount
    let areFieldWithAmountsEqual = lhs.fieldWithAmount == rhs.fieldWithAmount
    return areTotalAmountsEqual && areFieldWithAmountsEqual
  }
}

// MARK: - FieldType

@available(iOS 16.0, *)
extension CryptoConverterView {
  public enum FieldType: Equatable {
    case cryptocurrency
    case standart
  }
}

// MARK: - Equatable LeftSide

@available(iOS 16.0, *)
extension CryptoConverterView.LeftSide {
  public static func == (
    lhs: CryptoConverterView.LeftSide,
    rhs: CryptoConverterView.LeftSide
  ) -> Bool {
    let areTitlesEqual = lhs.title == rhs.title
    let areShortFormCryptoNamesEqual = lhs.shortFormCryptoName == rhs.shortFormCryptoName
    let areLongFormCryptoNamesEqual = lhs.longFormCryptoName == rhs.longFormCryptoName
    return areTitlesEqual && areShortFormCryptoNamesEqual && areLongFormCryptoNamesEqual
  }
}

// MARK: - Equatable Model

extension CryptoConverterView.Model {
  public static func == (
    lhs: CryptoConverterView.Model,
    rhs: CryptoConverterView.Model
  ) -> Bool {
    return lhs.fieldType == rhs.fieldType &&
    lhs.placeholder == rhs.placeholder &&
    lhs.leftSide == rhs.leftSide &&
    lhs.rightSide == rhs.rightSide
  }
}
