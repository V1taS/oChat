//
//  ConfirmSendPaymentScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol ConfirmSendPaymentScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol ConfirmSendPaymentScreenFactoryInput {
  /// Создать заголовок для хелпера
  func createHelperTitle(tokenName: String) -> String
  /// Создать описание для хелпера
  func createHelperSubtitle() -> String
  /// Создать заголовок для кнопки
  func createMainButtonTitle() -> String
  /// Создаем список моделек для отображения
  func createWidgetCryptoModels(
    myWalletAddress: String,
    recipientAddress: String,
    transactionFee: Decimal,
    model: TokenModel
  ) -> [WidgetCryptoView.Model]
}

/// Фабрика
final class ConfirmSendPaymentScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: ConfirmSendPaymentScreenFactoryOutput?
}

// MARK: - ConfirmSendPaymentScreenFactoryInput

extension ConfirmSendPaymentScreenFactory: ConfirmSendPaymentScreenFactoryInput {
  func createHelperTitle(tokenName: String) -> String {
    OChatStrings.ConfirmSendPaymentScreenLocalization
      .State.Helper.title(tokenName)
  }
  
  func createHelperSubtitle() -> String {
    OChatStrings.ConfirmSendPaymentScreenLocalization
      .State.Helper.subtitle
  }
  
  func createMainButtonTitle() -> String {
    OChatStrings.ConfirmSendPaymentScreenLocalization
      .State.MainButton.title
  }
  
  func createWidgetCryptoModels(
    myWalletAddress: String,
    recipientAddress: String,
    transactionFee: Decimal,
    model: TokenModel
  ) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    let walletAddress = createWidgetModel(
      leftTitle: OChatStrings.ConfirmSendPaymentScreenLocalization
        .State.MyAddress.title,
      rightTitle: myWalletAddress.formatString(minTextLength: 20)
    )
    models.append(walletAddress)
    
    let recipient = createWidgetModel(
      leftTitle: OChatStrings.ConfirmSendPaymentScreenLocalization
        .State.Recipient.title,
      rightTitle: recipientAddress.formatString(minTextLength: 20)
    )
    models.append(recipient)
    
    let pricePerToken = model.currency?.pricePerToken ?? .zero
    let symbol = model.currency?.type.details.symbol ?? ""
    
    let amount = createWidgetModel(
      leftTitle: OChatStrings.ConfirmSendPaymentScreenLocalization
        .State.TokenAmount.title,
      rightTitle: model.tokenAmount.format(currency: model.ticker),
      rightDescreption: "\(Constants.approxSign) \(model.costInCurrency.format(currency: symbol))"
    )
    models.append(amount)
    
    let fee = createWidgetModel(
      leftTitle: OChatStrings.ConfirmSendPaymentScreenLocalization
        .State.Fee.title,
      rightTitle: "\(Constants.approxSign) \(transactionFee.format(currency: model.ticker))",
      rightDescreption: "\(Constants.approxSign) \((transactionFee * pricePerToken).format(currency: symbol))"
    )
    models.append(fee)
    
    return models
  }
}

// MARK: - Private

private extension ConfirmSendPaymentScreenFactory {
  func createWidgetModel(
    leftTitle: String,
    rightTitle: String,
    rightDescreption: String? = nil
  ) -> WidgetCryptoView.Model {
    var rightDescriptionModel: WidgetCryptoView.TextModel?
    
    if let rightDescreption {
      rightDescriptionModel = .init(
        text: rightDescreption,
        lineLimit: 1,
        textStyle: .netural
      )
    }
    
    return .init(
      leftSide: .init(
        titleModel: .init(
          text: leftTitle,
          lineLimit: 1,
          textStyle: .netural
        )
      ),
      rightSide: .init(
        titleModel: .init(
          text: rightTitle,
          lineLimit: 1,
          textStyle: .standart
        ),
        descriptionModel: rightDescriptionModel
      ),
      isSelectable: false
    )
  }
}

// MARK: - Constants

private enum Constants {
  static let approxSign = "\u{2248}"
}
