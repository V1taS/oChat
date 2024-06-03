//
//  ReceivePaymentScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//

import SwiftUI
import SKAbstractions
import SKUIKit

/// Cобытия которые отправляем из Factory в Presenter
protocol ReceivePaymentScreenFactoryOutput: AnyObject {
  /// Открыть экран выбора сети для Токена
  func openNetworkSelectionScreen()
  /// Открыть экран выбора Токена
  func openListTokensScreen()
}

/// Cобытия которые отправляем от Presenter к Factory
protocol ReceivePaymentScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать заголовок для кнопки
  func createButtonTitle() -> String
  /// Список виджетов для отображения экрана
  func createWidgetModels(
    _ model: TokenModel
  ) -> [ReceivePaymentScreenModel]
  /// Обновить данные по токену
  func updateTokenModelWith(
    _ networkType: SKAbstractions.TokenNetworkType,
    tokenModel: TokenModel
  ) -> TokenModel
}

/// Фабрика
final class ReceivePaymentScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: ReceivePaymentScreenFactoryOutput?
}

// MARK: - ReceivePaymentScreenFactoryInput

extension ReceivePaymentScreenFactory: ReceivePaymentScreenFactoryInput {
  func updateTokenModelWith(
    _ networkType: SKAbstractions.TokenNetworkType,
    tokenModel: TokenModel
  ) -> TokenModel {
    return TokenModel(
      name: tokenModel.name,
      ticker: tokenModel.ticker,
      address: tokenModel.address,
      decimals: tokenModel.decimals,
      eip2612: tokenModel.eip2612,
      isFeeOnTransfer: tokenModel.isFeeOnTransfer,
      network: networkType,
      availableNetworks: tokenModel.availableNetworks,
      tokenAmount: tokenModel.tokenAmount,
      currency: tokenModel.currency,
      isActive: tokenModel.isActive,
      logoURI: tokenModel.imageTokenURL?.absoluteString
    )
  }
  
  func createHeaderTitle() -> String {
    OChatStrings.ReceivePaymentScreenLocalization
      .State.Header.title
  }
  
  func createButtonTitle() -> String {
    OChatStrings.ReceivePaymentScreenLocalization
      .State.Button.title
  }
  
  func createWidgetModels(
    _ model: TokenModel
  ) -> [ReceivePaymentScreenModel] {
    var models: [ReceivePaymentScreenModel] = []
    
    let token = ReceivePaymentScreenModel(
      id: UUID().uuidString,
      title: OChatStrings.ReceivePaymentScreenLocalization
        .State.TokenSection.title,
      widget: createWidget(
        with: model.name,
        imageURL: model.imageTokenURL,
        action: { [weak self] in
          self?.output?.openListTokensScreen()
        }
      )
    )
    
    let networkSection = ReceivePaymentScreenModel(
      id: UUID().uuidString,
      title: OChatStrings.ReceivePaymentScreenLocalization
        .State.NetworkSection.title,
      widget: createWidget(
        with: model.network.details.name,
        imageURL: model.network.imageNetworkURL,
        action: { [weak self] in
          self?.output?.openNetworkSelectionScreen()
        }
      )
    )
    
    models = [
      token,
      networkSection
    ]
    return models
  }
}

// MARK: - Private

private extension ReceivePaymentScreenFactory {
  func createWidget(
    with title: String,
    imageURL: URL?,
    action: (() -> Void)?
  ) -> WidgetCryptoView.Model {
    return .init(
      leftSide: .init(
        imageModel: .custom(imageURL: imageURL),
        titleModel: .init(
          text: title,
          textStyle: .standart
        ),
        titleAdditionModel: nil,
        titleAdditionRoundedModel: nil,
        descriptionModel: nil,
        descriptionAdditionModel: nil,
        descriptionAdditionRoundedModel: nil
      ),
      rightSide: .init(
        imageModel: .chevron,
        titleModel: nil
      ),
      isSelectable: true,
      backgroundColor: nil,
      action: {
        action?()
      }
    )
  }
}

// MARK: - Constants

private enum Constants {}
