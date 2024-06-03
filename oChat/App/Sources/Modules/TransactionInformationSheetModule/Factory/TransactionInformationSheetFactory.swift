//
//  TransactionInformationSheetFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 07.05.2024.
//

import SwiftUI
import SKAbstractions
import SKUIKit
import SKStyle

/// Cобытия которые отправляем из Factory в Presenter
protocol TransactionInformationSheetFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol TransactionInformationSheetFactoryInput {
  /// Создать заголовок у кнопки
  func createTransactionButtonTitle() -> String
  /// Создание модельки для шторки
  func createWidgetList(_ transactionModel: TransactionModel) -> [WidgetCryptoView.Model]
}

/// Фабрика
final class TransactionInformationSheetFactory {
  
  // MARK: - Internal properties
  
  weak var output: TransactionInformationSheetFactoryOutput?
}

// MARK: - TransactionInformationSheetFactoryInput

extension TransactionInformationSheetFactory: TransactionInformationSheetFactoryInput {
  func createTransactionButtonTitle() -> String {
    OChatStrings.TransactionInformationSheetLocalization
      .State.Transaction.Button.title
  }
  
  func createWidgetList(_ transactionModel: TransactionModel) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    models.append(createAddressRecipientWidget(transactionModel))
    models.append(createFeeWidget(transactionModel))
    return models
  }
}

// MARK: - Private

private extension TransactionInformationSheetFactory {
  func createAddressRecipientWidget(_ transactionModel: TransactionModel) -> WidgetCryptoView.Model {
    let recipientTitle = transactionModel.transactionType == .sent ? 
    OChatStrings.TransactionInformationSheetLocalization
      .State.Transaction.Sent.title :
    OChatStrings.TransactionInformationSheetLocalization
      .State.Transaction.Received.title
    let address = OChatStrings.TransactionInformationSheetLocalization
      .State.Transaction.Address.title
    return .init(
      leftSide: .init(
        titleModel: .init(
          text: "\(address) \(recipientTitle)",
          lineLimit: 1,
          textStyle: .standart
        ),
        descriptionModel: .init(
          text: "\(transactionModel.addressRecipient)",
          lineLimit: .max,
          textStyle: .netural
        )
      ),
      isSelectable: false,
      backgroundColor: SKStyleAsset.constantSlate.swiftUIColor.opacity(0.1)
    )
  }
  
  func createFeeWidget(_ transactionModel: TransactionModel) -> WidgetCryptoView.Model {
    let tokenAmount = "\(abs(transactionModel.commissionAmount))".formattedWithSpaces()
    let tokenSymbol = transactionModel.token.ticker
    let currency = transactionModel.token.currency
    let costInCurrency = "\(abs(transactionModel.commissionInCurrency))".formattedWithSpaces()
    let commission = OChatStrings.TransactionInformationSheetLocalization
      .State.Transaction.Commission.title
    
    return .init(
      leftSide: .init(
        titleModel: .init(
          text: "\(commission)",
          lineLimit: 1,
          textStyle: .standart
        )
      ),
      rightSide: .init(
        titleModel: .init(
          text: "\(tokenAmount) \(tokenSymbol)",
          lineLimit: .max,
          textStyle: .standart
        ),
        descriptionModel: .init(
          text: "\(costInCurrency) \(currency)",
          lineLimit: .max,
          textStyle: .netural
        )
      ),
      isSelectable: false,
      backgroundColor: SKStyleAsset.constantSlate.swiftUIColor.opacity(0.1)
    )
  }
}

// MARK: - Constants

private enum Constants {}
