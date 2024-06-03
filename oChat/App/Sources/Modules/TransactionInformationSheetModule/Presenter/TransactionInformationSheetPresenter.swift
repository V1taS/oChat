//
//  TransactionInformationSheetPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 07.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions
import SKFoundation

final class TransactionInformationSheetPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateTransactionModel: TransactionModel
  @Published var stateWidgetCryptoModels: [WidgetCryptoView.Model] = []
  
  // MARK: - Internal properties
  
  weak var moduleOutput: TransactionInformationSheetModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: TransactionInformationSheetInteractorInput
  private let factory: TransactionInformationSheetFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - model: Модель транзакции
  init(interactor: TransactionInformationSheetInteractorInput,
       factory: TransactionInformationSheetFactoryInput,
       _ model: TransactionModel) {
    self.interactor = interactor
    self.factory = factory
    self.stateTransactionModel = model
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    stateWidgetCryptoModels = factory.createWidgetList(stateTransactionModel)
  }
  
  // MARK: - Internal func
  
  func getTokenAmountTitle() -> String {
    let sign = stateTransactionModel.transactionType.sign
    let tokenAmount = "\(abs(stateTransactionModel.amount))".formattedWithSpaces()
    let tokenSymbol = stateTransactionModel.token.ticker
    
    return "\(sign) \(tokenAmount) \(tokenSymbol)"
  }
  
  func getCurrencyAmountTitle() -> String {
    let currency = stateTransactionModel.token.currency
    let costInCurrency = "\(abs(stateTransactionModel.costInCurrency))".formattedWithSpaces()
    return "\(costInCurrency) \(currency)"
  }
  
  func getDateTitle() -> String {
    let title = stateTransactionModel.transactionType.title
    let date = stateTransactionModel.date
    return "\(title) \(date)"
  }
  
  func getTransactionButtonTitle() -> String {
    factory.createTransactionButtonTitle()
  }
  
  func transactionButtonTapped() {
    interactor.openURLInSafari(urlString: stateTransactionModel.transactionWebLink)
  }
}

// MARK: - TransactionInformationSheetModuleInput

extension TransactionInformationSheetPresenter: TransactionInformationSheetModuleInput {}

// MARK: - TransactionInformationSheetInteractorOutput

extension TransactionInformationSheetPresenter: TransactionInformationSheetInteractorOutput {}

// MARK: - TransactionInformationSheetFactoryOutput

extension TransactionInformationSheetPresenter: TransactionInformationSheetFactoryOutput {}

// MARK: - SceneViewModel

extension TransactionInformationSheetPresenter: SceneViewModel {
  var backgroundColor: UIColor? {
    SKStyleAsset.sheet.color
  }
}

// MARK: - Private

private extension TransactionInformationSheetPresenter {}

// MARK: - Constants

private enum Constants {}
