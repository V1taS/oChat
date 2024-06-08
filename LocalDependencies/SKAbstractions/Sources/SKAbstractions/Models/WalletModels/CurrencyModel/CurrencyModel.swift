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
        AbstractionsStrings.CurrencyModelLocalization.usdName,
        AbstractionsStrings.CurrencyModelLocalization.usdUnit,
        "$"
      )
    case .eur:
      return (
        "EUR",
        "978",
        AbstractionsStrings.CurrencyModelLocalization.eurName,
        AbstractionsStrings.CurrencyModelLocalization.eurUnit,
        "€"
      )
    case .rub:
      return (
        "RUB",
        "643",
        AbstractionsStrings.CurrencyModelLocalization.rubName,
        AbstractionsStrings.CurrencyModelLocalization.rubUnit,
        "₽"
      )
    case .idr:
      return (
        "IDR",
        "360",
        AbstractionsStrings.CurrencyModelLocalization.idrName,
        AbstractionsStrings.CurrencyModelLocalization.idrUnit,
        "Rp"
      )
    case .uah:
      return (
        "UAH",
        "980",
        AbstractionsStrings.CurrencyModelLocalization.uahName,
        AbstractionsStrings.CurrencyModelLocalization.uahUnit,
        "₴"
      )
    case .inr:
      return (
        "INR",
        "356",
        AbstractionsStrings.CurrencyModelLocalization.inrName,
        AbstractionsStrings.CurrencyModelLocalization.inrUnit,
        "₹"
      )
    case .gbp:
      return (
        "GBP",
        "826",
        AbstractionsStrings.CurrencyModelLocalization.gbpName,
        AbstractionsStrings.CurrencyModelLocalization.gbpUnit,
        "£"
      )
    case .aed:
      return (
        "AED",
        "784",
        AbstractionsStrings.CurrencyModelLocalization.aedName,
        AbstractionsStrings.CurrencyModelLocalization.aedUnit,
        "د.إ"
      )
    case .cny:
      return (
        "CNY",
        "156",
        AbstractionsStrings.CurrencyModelLocalization.cnyName,
        AbstractionsStrings.CurrencyModelLocalization.cnyUnit,
        "¥"
      )
    case .brl:
      return (
        "BRL",
        "986",
        AbstractionsStrings.CurrencyModelLocalization.brlName,
        AbstractionsStrings.CurrencyModelLocalization.brlUnit,
        "R$"
      )
    case .try:
      return (
        "TRY",
        "949",
        AbstractionsStrings.CurrencyModelLocalization.tryName,
        AbstractionsStrings.CurrencyModelLocalization.tryUnit,
        "₺"
      )
    case .ngn:
      return (
        "NGN",
        "566",
        AbstractionsStrings.CurrencyModelLocalization.ngnName,
        AbstractionsStrings.CurrencyModelLocalization.ngnUnit,
        "₦"
      )
    case .krw:
      return (
        "KRW",
        "410",
        AbstractionsStrings.CurrencyModelLocalization.krwName,
        AbstractionsStrings.CurrencyModelLocalization.krwUnit,
        "₩"
      )
    case .thb:
      return (
        "THB",
        "764",
        AbstractionsStrings.CurrencyModelLocalization.thbName,
        AbstractionsStrings.CurrencyModelLocalization.thbUnit,
        "฿"
      )
    case .bdt:
      return (
        "BDT",
        "050",
        AbstractionsStrings.CurrencyModelLocalization.bdtName,
        AbstractionsStrings.CurrencyModelLocalization.bdtUnit,
        "৳"
      )
    case .chf:
      return (
        "CHF",
        "756",
        AbstractionsStrings.CurrencyModelLocalization.chfName,
        AbstractionsStrings.CurrencyModelLocalization.chfUnit,
        "₣"
      )
    case .jpy:
      return (
        "JPY",
        "392",
        AbstractionsStrings.CurrencyModelLocalization.jpyName,
        AbstractionsStrings.CurrencyModelLocalization.jpyUnit,
        "¥"
      )
    case .cad:
      return (
        "CAD",
        "124",
        AbstractionsStrings.CurrencyModelLocalization.cadName,
        AbstractionsStrings.CurrencyModelLocalization.cadUnit,
        "$"
      )
    case .ils:
      return (
        "ILS",
        "376",
        AbstractionsStrings.CurrencyModelLocalization.ilsName,
        AbstractionsStrings.CurrencyModelLocalization.ilsUnit,
        "₪"
      )
    case .vnd:
      return (
        "VND",
        "704",
        AbstractionsStrings.CurrencyModelLocalization.vndName,
        AbstractionsStrings.CurrencyModelLocalization.vndUnit,
        "₫"
      )
    }
  }
}

// MARK: - IdentifiableAndCodable

extension CurrencyModel: IdentifiableAndCodable {}
extension CurrencyModel.CurrencyType: IdentifiableAndCodable {}
