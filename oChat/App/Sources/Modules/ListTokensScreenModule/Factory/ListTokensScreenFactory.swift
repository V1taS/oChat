//
//  ListTokensScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 25.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol ListTokensScreenFactoryOutput: AnyObject {
  /// Токен был выбран
  func tokenSelected(_ model: TokenModel)
  
  /// Токен был активирован или деактивирован
  func tokenIsActive(_ model: TokenModel, value: Bool)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol ListTokensScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle(_ screenType: ListTokensScreenType) -> String
  /// Просто список токенов какой то сети
  func createTokenSelectioList(
    listTokenModels: [TokenModel]
  ) -> [WidgetCryptoView.Model]
  
  /// Список всех токенов для добавления на главный экран
  func createAddTokenOnMainScreenList(
    listTokenModels: [TokenModel]
  ) -> [WidgetCryptoView.Model]
}

/// Фабрика
final class ListTokensScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: ListTokensScreenFactoryOutput?
}

// MARK: - ListTokensScreenFactoryInput

extension ListTokensScreenFactory: ListTokensScreenFactoryInput {
  func createTokenSelectioList(
    listTokenModels: [TokenModel]
  ) -> [SKUIKit.WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    listTokenModels.forEach { model in
      models.append(createListSelectioWidget(model))
    }
    return models
  }
  
  func createAddTokenOnMainScreenList(
    listTokenModels: [TokenModel]
  ) -> [SKUIKit.WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    listTokenModels.forEach { model in
      models.append(createAddTokenOnMainScreenWidget(model))
    }
    return models
  }
  
  func createHeaderTitle(_ screenType: ListTokensScreenType) -> String {
    switch screenType {
    case .tokenSelectioList:
      return oChatStrings.ListTokensScreenLocalization
        .State.TokenSelectio.Header.title
    case .addTokenOnMainScreen:
      return oChatStrings.ListTokensScreenLocalization
        .State.AddToken.Header.title
    }
  }
  
  func createListSelectioWidget(_ model: TokenModel) -> WidgetCryptoView.Model {
    return .init(
      leftSide: .init(
        imageModel: .custom(imageURL: model.imageTokenURL),
        titleModel: .init(
          text: model.ticker
        ),
        titleAdditionModel: nil,
        titleAdditionRoundedModel: nil,
        descriptionModel: .init(
          text: model.network.details.name,
          textStyle: .netural
        ),
        descriptionAdditionModel: nil,
        descriptionAdditionRoundedModel: nil
      ),
      rightSide: .init(
        titleModel: .init(
          text: model.tokenAmount.format()
        ),
        descriptionModel: .init(
          text: model.costInCurrency.format(
            currency: model.currency?.type.details.symbol,
            formatType: .precise
          )
        )
      ),
      additionCenterTextModel: nil,
      additionCenterContent: nil,
      isSelectable: true,
      action: { [weak self] in
        self?.output?.tokenSelected(model)
      }
    )
  }
  
  func createAddTokenOnMainScreenWidget(_ model: TokenModel) -> WidgetCryptoView.Model {
    return .init(
      leftSide: .init(
        imageModel: .custom(imageURL: model.imageTokenURL),
        titleModel: .init(
          text: model.ticker
        ),
        titleAdditionModel: nil,
        titleAdditionRoundedModel: .init(
          text: model.network.details.tokenType,
          textStyle: .netural
        ),
        descriptionModel: .init(
          text: model.network.details.name,
          textStyle: .netural
        ),
        descriptionAdditionModel: nil,
        descriptionAdditionRoundedModel: nil
      ),
      rightSide: .init(
        itemModel: .switcher(
          initNewValue: model.isActive,
          action: { [weak self] newValue in
            self?.output?.tokenIsActive(model, value: newValue)
          }
        ),
        titleModel: nil
      ),
      additionCenterTextModel: nil,
      additionCenterContent: nil,
      isSelectable: false
    )
  }
}

// MARK: - Private

private extension ListTokensScreenFactory {}

// MARK: - Constants

private enum Constants {}
