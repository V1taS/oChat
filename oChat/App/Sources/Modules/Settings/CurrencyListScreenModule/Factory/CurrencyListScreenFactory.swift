//
//  CurrencyListScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol CurrencyListScreenFactoryOutput: AnyObject {
  /// Пользователь выбрал валюту
  func currentCurrencyTapped(_ currency: CurrencyModel)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol CurrencyListScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать виджет модельки для отображения
  func createWidgetModels(_ currency: CurrencyModel) -> [WidgetCryptoView.Model]
}

/// Фабрика
final class CurrencyListScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: CurrencyListScreenFactoryOutput?
}

// MARK: - CurrencyListScreenFactoryInput

extension CurrencyListScreenFactory: CurrencyListScreenFactoryInput {
  func createHeaderTitle() -> String {
    oChatStrings.CurrencyListScreenLocalization
      .State.Header.title
  }
  
  func createWidgetModels(_ currency: CurrencyModel) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    CurrencyModel.CurrencyType.allCases.forEach { model in
      let usdModel = createWidgetModel(
        title: model.details.id,
        description: model.details.name,
        initNewValue: currency.type == model,
        isChangeValue: currency.type != model,
        action: { [weak self] _ in
          self?.output?.currentCurrencyTapped(CurrencyModel(type: model, pricePerToken: .zero))
        },
        currency: currency
      )
      models.append(usdModel)
    }
    return models
  }
}

// MARK: - Private

private extension CurrencyListScreenFactory {
  func createWidgetModel(
    title: String,
    description: String,
    initNewValue: Bool,
    isChangeValue: Bool,
    action: ((Bool) -> Void)?,
    currency: CurrencyModel
  ) -> WidgetCryptoView.Model {
    return .init(
      leftSide: .init(
        titleModel: .init(
          text: title,
          lineLimit: 1,
          textStyle: .standart
        ),
        titleAdditionModel: .init(
          text: description,
          lineLimit: 1,
          textStyle: .netural
        )
      ),
      rightSide: .init(
        itemModel: .radioButtons(
          initNewValue: initNewValue,
          isChangeValue: isChangeValue,
          action: action
        )
      ),
      isSelectable: true) { [weak self] in
        if !initNewValue {
          self?.output?.currentCurrencyTapped(currency)
        }
      }
  }
}

// MARK: - Constants

private enum Constants {}
