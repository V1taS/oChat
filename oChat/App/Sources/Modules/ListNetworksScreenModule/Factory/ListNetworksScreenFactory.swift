//
//  ListNetworksScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import SwiftUI
import SKUIKit
import SKStyle
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol ListNetworksScreenFactoryOutput: AnyObject {
  /// Сеть блок чейна выбрана был выбран
  func networkSelected(_ model: TokenNetworkType)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol ListNetworksScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Список доступных сетей
  func createNetworkSelectioList(
    currentNetwork: TokenNetworkType,
    _ listNetwork: [TokenNetworkType]
  ) -> [WidgetCryptoView.Model]
}

/// Фабрика
final class ListNetworksScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: ListNetworksScreenFactoryOutput?
}

// MARK: - ListNetworksScreenFactoryInput

extension ListNetworksScreenFactory: ListNetworksScreenFactoryInput {
  func createNetworkSelectioList(
    currentNetwork: TokenNetworkType,
    _ listNetwork: [TokenNetworkType]
  ) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    listNetwork.forEach { model in
      if currentNetwork.details.ticker == model.details.ticker {
        models.append(createWidget(isSelected: true, model: model))
      } else {
        models.append(createWidget(isSelected: false, model: model))
      }
    }
    return models
  }
  
  func createHeaderTitle() -> String {
    OChatStrings.ListNetworksScreenLocalization
      .State.Header.title
  }
}

// MARK: - Private

private extension ListNetworksScreenFactory {
  func createWidget(isSelected: Bool, model: TokenNetworkType) -> WidgetCryptoView.Model {
    var imageModel: WidgetCryptoView.ImageModel?
    
    if isSelected {
      imageModel = .custom(
        image: Image(systemName: "checkmark.circle.fill"),
        color: SKStyleAsset.azure.swiftUIColor,
        size: .standart
      )
    }
    
    return .init(
      leftSide: .init(
        imageModel: .custom(imageURL: model.imageNetworkURL),
        titleModel: .init(
          text: model.details.name,
          textStyle: .standart
        ),
        titleAdditionModel: nil,
        titleAdditionRoundedModel: nil,
        descriptionModel: nil,
        descriptionAdditionModel: nil,
        descriptionAdditionRoundedModel: nil
      ),
      rightSide: .init(
        imageModel: imageModel,
        titleModel: nil
      ),
      additionCenterTextModel: nil,
      additionCenterContent: nil,
      isSelectable: true,
      action: { [weak self] in
        self?.output?.networkSelected(model)
      }
    )
  }
}

// MARK: - Constants

private enum Constants {}
