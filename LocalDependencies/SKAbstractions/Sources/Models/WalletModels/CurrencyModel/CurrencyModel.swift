//
//  CurrencyModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import Foundation

// MARK: - CurrencyModel

/// Структура для представления модели валюты с текущим курсом.
public struct CurrencyModel {
  /// Тип валюты.
  public let type: CurrencyType
  /// Цена за одну единицу криптовалюты в фиатной валюте.
  public var pricePerToken: Decimal
  
  /// Публичный инициализатор для создания экземпляра `CurrencyModel`.
  /// - Parameters:
  ///   - type: Тип валюты
  ///   - pricePerToken: Цена за одну единицу валюты в фиатной валюте, например в долларах США.
  public init(
    type: CurrencyType,
    pricePerToken: Decimal
  ) {
    self.type = type
    self.pricePerToken = pricePerToken
  }
}

// MARK: - CurrencyType

extension CurrencyModel {
  /// Перечисление для представления валют с их основными характеристиками.
  public enum CurrencyType: String, CaseIterable {
    /// Американский доллар.
    case usd
    /// Евро.
    case eur
    /// Российский рубль.
    case rub
    /// Индонезийская рупия.
    case idr
    /// Украинская гривна.
    case uah
    /// Индийская рупия.
    case inr
    /// Британский фунт стерлингов.
    case gbp
    /// Дирхам Объединенных Арабских Эмиратов.
    case aed
    /// Китайский юань.
    case cny
    /// Бразильский реал.
    case brl
    /// Турецкая лира.
    case `try`
    /// Нигерийская найра.
    case ngn
    /// Южнокорейская вона.
    case krw
    /// Тайский бат.
    case thb
    /// Бангладешская така.
    case bdt
    /// Швейцарский франк.
    case chf
    /// Японская иена.
    case jpy
    /// Канадский доллар.
    case cad
    /// Израильский шекель.
    case ils
    /// Вьетнамский донг.
    case vnd
  }
}

// MARK: - Details

extension CurrencyModel.CurrencyType {
  /// Возвращает кортеж с основными характеристиками валюты:
  /// ID (USD), код валюты (840), полное название (Доллар США), единицу измерения (доллар) и символ ($).
  public var details: (id: String, code: String, name: String, unit: String, symbol: String) {
    switch self {
    case .usd:
      return (
        "USD",
        "840",
        SKAbstractionsStrings.CurrencyModelLocalization.Usd.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Usd.unit,
        "$"
      )
    case .eur:
      return (
        "EUR",
        "978",
        SKAbstractionsStrings.CurrencyModelLocalization.Eur.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Eur.unit,
        "€"
      )
    case .rub:
      return (
        "RUB",
        "643",
        SKAbstractionsStrings.CurrencyModelLocalization.Rub.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Rub.unit,
        "₽"
      )
    case .idr:
      return (
        "IDR",
        "360",
        SKAbstractionsStrings.CurrencyModelLocalization.Idr.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Idr.unit,
        "Rp"
      )
    case .uah:
      return (
        "UAH",
        "980",
        SKAbstractionsStrings.CurrencyModelLocalization.Uah.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Uah.unit,
        "₴"
      )
    case .inr:
      return (
        "INR",
        "356",
        SKAbstractionsStrings.CurrencyModelLocalization.Inr.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Inr.unit,
        "₹"
      )
    case .gbp:
      return (
        "GBP",
        "826",
        SKAbstractionsStrings.CurrencyModelLocalization.Gbp.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Gbp.unit,
        "£"
      )
    case .aed:
      return (
        "AED",
        "784",
        SKAbstractionsStrings.CurrencyModelLocalization.Aed.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Aed.unit,
        "د.إ"
      )
    case .cny:
      return (
        "CNY",
        "156",
        SKAbstractionsStrings.CurrencyModelLocalization.Cny.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Cny.unit,
        "¥"
      )
    case .brl:
      return (
        "BRL",
        "986",
        SKAbstractionsStrings.CurrencyModelLocalization.Brl.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Brl.unit,
        "R$"
      )
    case .try:
      return (
        "TRY",
        "949",
        SKAbstractionsStrings.CurrencyModelLocalization.Try.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Try.unit,
        "₺"
      )
    case .ngn:
      return (
        "NGN",
        "566",
        SKAbstractionsStrings.CurrencyModelLocalization.Ngn.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Ngn.unit,
        "₦"
      )
    case .krw:
      return (
        "KRW",
        "410",
        SKAbstractionsStrings.CurrencyModelLocalization.Krw.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Krw.unit,
        "₩"
      )
    case .thb:
      return (
        "THB",
        "764",
        SKAbstractionsStrings.CurrencyModelLocalization.Thb.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Thb.unit,
        "฿"
      )
    case .bdt:
      return (
        "BDT",
        "050",
        SKAbstractionsStrings.CurrencyModelLocalization.Bdt.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Bdt.unit,
        "৳"
      )
    case .chf:
      return (
        "CHF",
        "756",
        SKAbstractionsStrings.CurrencyModelLocalization.Chf.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Chf.unit,
        "₣"
      )
    case .jpy:
      return (
        "JPY",
        "392",
        SKAbstractionsStrings.CurrencyModelLocalization.Jpy.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Jpy.unit,
        "¥"
      )
    case .cad:
      return (
        "CAD",
        "124",
        SKAbstractionsStrings.CurrencyModelLocalization.Cad.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Cad.unit,
        "$"
      )
    case .ils:
      return (
        "ILS",
        "376",
        SKAbstractionsStrings.CurrencyModelLocalization.Ils.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Ils.unit,
        "₪"
      )
    case .vnd:
      return (
        "VND",
        "704",
        SKAbstractionsStrings.CurrencyModelLocalization.Vnd.name,
        SKAbstractionsStrings.CurrencyModelLocalization.Vnd.unit,
        "₫"
      )
    }
  }
}

// MARK: - IdentifiableAndCodable

extension CurrencyModel: IdentifiableAndCodable {}
extension CurrencyModel.CurrencyType: IdentifiableAndCodable {}
