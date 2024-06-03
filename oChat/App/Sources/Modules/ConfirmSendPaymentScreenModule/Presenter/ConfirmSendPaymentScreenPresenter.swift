//
//  ConfirmSendPaymentScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class ConfirmSendPaymentScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateTokenModel: TokenModel
  @Published var stateRecipientAddress: String
  @Published var stateMyWalletAddress = ""
  @Published var stateWidgetCryptoModels: [WidgetCryptoView.Model] = []
  
  // MARK: - Internal properties
  
  weak var moduleOutput: ConfirmSendPaymentScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: ConfirmSendPaymentScreenInteractorInput
  private let factory: ConfirmSendPaymentScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - tokenModel: Моделька токена
  ///   - recipientAddress: Адрес получателя
  init(interactor: ConfirmSendPaymentScreenInteractorInput,
       factory: ConfirmSendPaymentScreenFactoryInput,
       tokenModel: TokenModel,
       recipientAddress: String) {
    self.interactor = interactor
    self.factory = factory
    self.stateTokenModel = tokenModel
    self.stateRecipientAddress = recipientAddress
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    interactor.getMyWalletAddress()
  }
  
  // MARK: - Internal func
  
  func getHelperTitle() -> String {
    factory.createHelperTitle(tokenName: stateTokenModel.ticker)
  }
  
  func getHelperSubtitle() -> String {
    factory.createHelperSubtitle()
  }
  
  func getMainButtonTitle() -> String {
    factory.createMainButtonTitle()
  }
  
  func passTokenSendingValidation() {
    interactor.passTokenSendingValidation()
  }
}

// MARK: - ConfirmSendPaymentScreenModuleInput

extension ConfirmSendPaymentScreenPresenter: ConfirmSendPaymentScreenModuleInput {}

// MARK: - ConfirmSendPaymentScreenInteractorOutput

extension ConfirmSendPaymentScreenPresenter: ConfirmSendPaymentScreenInteractorOutput {
  func paymentSentSuccessfully() {
    moduleOutput?.paymentSentSuccessfully()
  }
  
  func paymentNotSent() {
    moduleOutput?.paymentNotSent()
  }
  
  func didReceiveTransactionFee(_ transactionFee: Decimal) {
    stateWidgetCryptoModels = factory.createWidgetCryptoModels(
      myWalletAddress: stateMyWalletAddress,
      recipientAddress: stateRecipientAddress,
      transactionFee: transactionFee,
      model: stateTokenModel
    )
  }
  
  func didReceiveMyWalletAddress(_ walletAddress: String) {
    stateMyWalletAddress = walletAddress
    interactor.getTransactionFee()
  }
}

// MARK: - ConfirmSendPaymentScreenFactoryOutput

extension ConfirmSendPaymentScreenPresenter: ConfirmSendPaymentScreenFactoryOutput {}

// MARK: - SceneViewModel

extension ConfirmSendPaymentScreenPresenter: SceneViewModel {}

// MARK: - Private

private extension ConfirmSendPaymentScreenPresenter {}

// MARK: - Constants

private enum Constants {}
