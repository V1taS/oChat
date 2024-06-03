//
//  MainScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol MainScreenFactoryOutput: AnyObject {
  /// Открыть экран добавление нового токена или выключения ненужных
  func openAddTokenScreen()
  /// Открыть экран деталей по конкретной криптовалюте
  func openDetailCoinScreen(_ model: TokenModel)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol MainScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать заголовок для кнопки отправки криптовалюты
  func createSendButtonTitle() -> String
  /// Создать заголовок для кнопки получения криптовалюты
  func createReceiveButtonTitle() -> String
  /// Создать список криптовалют на главном экране
  func createCryptoCurrencyList(_ tokenModels: [TokenModel]) -> [WidgetCryptoView.Model]
}

/// Фабрика
final class MainScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: MainScreenFactoryOutput?
}

// MARK: - MainScreenFactoryInput

extension MainScreenFactory: MainScreenFactoryInput {
  func createSendButtonTitle() -> String {
    return OChatStrings.MainScreenLocalization
      .State.Button.Send.title
  }
  
  func createReceiveButtonTitle() -> String {
    return OChatStrings.MainScreenLocalization
      .State.Button.Receive.title
  }
  
  func createHeaderTitle() -> String {
    return OChatStrings.MainScreenLocalization
      .State.Header.title
  }
  
  func createCryptoCurrencyList(_ tokenModels: [TokenModel]) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    let listCryptoCurrencyModels = tokenModels.filter({ $0.isActive }).compactMap { model in
      createCryptoWidget(model)
    }
    models.append(contentsOf: listCryptoCurrencyModels)
    let addTokenModel = createAddTokenWidget()
    models.append(addTokenModel)
    return models
  }
}

// MARK: - Private

private extension MainScreenFactory {
  func createAddTokenWidget() -> WidgetCryptoView.Model {
    return .init(
      leftSide: .init(
        titleModel: .init(
          text: OChatStrings.MainScreenLocalization
            .State.AddToken.title,
          textStyle: .netural
        )
      ),
      rightSide: .init(
        imageModel: .chevron,
        titleModel: nil,
        titleAdditionModel: nil,
        titleAdditionRoundedModel: nil,
        descriptionModel: nil,
        descriptionAdditionModel: nil,
        descriptionAdditionRoundedModel: nil
      ),
      isSelectable: true,
      action: { [weak self] in
        self?.output?.openAddTokenScreen()
      }
    )
  }
  
  func createCryptoWidget(_ model: TokenModel) -> WidgetCryptoView.Model {
    return .init(
      leftSide: .init(
        imageModel: .custom(imageURL: model.imageTokenURL),
        titleModel: .init(
          text: model.name,
          textStyle: .standart
        ),
        titleAdditionModel: nil,
        titleAdditionRoundedModel: .init(
          text: model.network.details.tokenType,
          textStyle: .netural
        ),
        descriptionModel: .init(
          text: model.currency?.pricePerToken.format(
            currency: model.currency?.type.details.symbol,
            formatType: .precise
          ) ?? "",
          textStyle: .netural,
          textIsSecure: false
        ),
        descriptionAdditionModel: .init(
          text: "+0.09%",
          textStyle: .positive,
          textIsSecure: false
        ),
        descriptionAdditionRoundedModel: nil
      ),
      rightSide: .init(
        imageModel: nil,
        titleModel: .init(
          text: model.tokenAmount.format(),
          textStyle: .standart,
          textIsSecure: false
        ),
        titleAdditionModel: nil,
        titleAdditionRoundedModel: nil,
        descriptionModel: .init(
          text: model.costInCurrency.format(
            currency: model.currency?.type.details.symbol,
            formatType: .precise
          ),
          textStyle: .netural
        ),
        descriptionAdditionModel: nil
      ),
      additionCenterTextModel: nil,
      additionCenterContent: nil,
      isSelectable: true,
      backgroundColor: nil,
      action: { [weak self] in
        self?.output?.openDetailCoinScreen(model)
      }
    )
  }
}

// MARK: - Constants

private enum Constants {}
