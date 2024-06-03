//
//  SendPaymentScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class SendPaymentScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateScreenModel: SendPaymentScreenModel
  @Published var stateIsCurrencySelected = true
  @Published var stateAmountToken: String = ""
  @Published var stateAddressRecipient: String = ""
  @Published var stateIsValidMainButton = false
  
  // MARK: - Internal properties
  
  weak var moduleOutput: SendPaymentScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: SendPaymentScreenInteractorInput
  private let factory: SendPaymentScreenFactoryInput
  private var barButtonView: SKBarButtonView?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - screenModel: Модель данных
  init(interactor: SendPaymentScreenInteractorInput,
       factory: SendPaymentScreenFactoryInput,
       screenModel: SendPaymentScreenModel) {
    self.interactor = interactor
    self.factory = factory
    self.stateScreenModel = screenModel
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    setupSKBarButtonView()
  }
  
  // MARK: - Internal func
  
  func getSendCryptoPlaceholderTitle() -> String {
    factory.createSendCryptoPlaceholderTitle()
  }
  
  func getSendCryptoHeaderTitle() -> String {
    factory.createSendCryptoHeaderTitle()
  }
  
  func getWhomCryptoHeaderTitle() -> String {
    factory.createWhomCryptoHeaderTitle()
  }
  
  func getMainButtonTitle() -> String {
    factory.createMainButtonTitle()
  }
  
  func getWhomCryptoPlaceholderTitle() -> String {
    factory.createWhomCryptoPlaceholderTitle()
  }
  
  func getTotalCryptoTitle() -> String {
    factory.createTotalCryptoTitle()
  }
  
  func getTotalCryptoMaxTitle() -> String {
    let tokenAmount = stateScreenModel.tokenModel.tokenAmount.format(formatType: .precise)
    let tokenSymbol = stateScreenModel.tokenModel.ticker
    return "\(tokenAmount) \(tokenSymbol)"
  }
  
  func applyMaximumAmount() {
    let tokenAmount = stateScreenModel.tokenModel.tokenAmount
    let exchangeRate = stateScreenModel.tokenModel.currency?.pricePerToken ?? .zero
    
    if stateIsCurrencySelected {
      // Когда выбрана валюта, основным полем является валюта, а второстепенным - крипта
      let currencyAmount = tokenAmount * exchangeRate
      let currencyAmountFormat = currencyAmount.format(formatType: .precise)
      stateAmountToken = currencyAmountFormat
    } else {
      // Когда выбрана крипта, основным полем является крипта, а второстепенным - валюта
      let cryptoAmountFormat = tokenAmount.format(formatType: .precise)
      stateAmountToken = cryptoAmountFormat
    }
    stateIsValidMainButton = isValidFields()
  }
  
  func switchCurrencyAction() {
    stateIsCurrencySelected.toggle()
    currencySwitch()
  }
  
  func currencySwitch() {
    let inputAmount = Decimal(string: stateAmountToken.removingSpaces()) ?? .zero
    let exchangeRate = stateScreenModel.tokenModel.currency?.pricePerToken ?? .zero
    
    if stateIsCurrencySelected {
      stateAmountToken = (inputAmount * exchangeRate).format(formatType: .precise)
    } else {
      stateAmountToken = (inputAmount / exchangeRate).format(formatType: .precise)
    }
  }
  
  func calculateCurrencyAndCrypto() -> (
    primaryName: String,
    primaryAmount: String,
    secondaryName: String,
    secondaryAmount: String
  ) {
    let currencyName = stateScreenModel.tokenModel.currency?.type.details.symbol ?? ""
    let cryptoName = stateScreenModel.tokenModel.ticker
    let inputAmount = Decimal(string: stateAmountToken.removingSpaces()) ?? .zero
    let exchangeRate = stateScreenModel.tokenModel.currency?.pricePerToken ?? .zero
    
    if stateIsCurrencySelected {
      // Когда выбрана валюта, основным полем является валюта, а второстепенным - крипта
      let currencyAmount = inputAmount
      let currencyAmountFormat = currencyAmount.format(formatType: .precise)
      let cryptoAmount = inputAmount / exchangeRate
      let cryptoAmountFormat = cryptoAmount.format(currency: cryptoName, formatType: .precise)
      return (currencyName, currencyAmountFormat, cryptoName, cryptoAmountFormat)
    } else {
      // Когда выбрана крипта, основным полем является крипта, а второстепенным - валюта
      let cryptoAmount = inputAmount
      let cryptoAmountFormat = cryptoAmount.format(formatType: .precise)
      let currencyAmount = inputAmount * exchangeRate
      let currencyAmountFormat = currencyAmount.format(currency: currencyName, formatType: .precise)
      return (cryptoName, cryptoAmountFormat, currencyName, currencyAmountFormat)
    }
  }
  
  func isValidFields() -> Bool {
    var inputAmount: Decimal = .zero
    let exchangeRate = stateScreenModel.tokenModel.currency?.pricePerToken ?? .zero
    
    if stateIsCurrencySelected {
      let input = Decimal(string: stateAmountToken.removingSpaces()) ?? .zero
      inputAmount = input / exchangeRate
    } else {
      let input = Decimal(string: stateAmountToken.removingSpaces()) ?? .zero
      inputAmount = input
    }
    
    if inputAmount == .zero {
      return false
    }
    
    let isAmountToken = inputAmount <= stateScreenModel.tokenModel.tokenAmount
    return isAmountToken && !stateAddressRecipient.isEmpty
  }
  
  func onAmountChange(_ value: String) {
    stateAmountToken = value.removingSpaces().formattedWithSpaces()
    stateIsValidMainButton = isValidFields()
  }
  
  func onAddressChange(_ value: String) {
    stateAddressRecipient = value
    stateIsValidMainButton = isValidFields()
  }
}

// MARK: - SendPaymentScreenModuleInput

extension SendPaymentScreenPresenter: SendPaymentScreenModuleInput {
  func networkSelected(_ model: SKAbstractions.TokenNetworkType) {
    stateScreenModel = factory.update(model: stateScreenModel, with: model)
    
    interactor.getImage(for: model.imageNetworkURL) { [weak self] image in
      guard let self else {
        return
      }
      barButtonView?.iconLeftView.image = image
    }
    
    barButtonView?.labelView.text = model.details.name
  }
  
  func tokenSelected(_ model: SKAbstractions.TokenModel) {
    stateScreenModel = factory.update(model: stateScreenModel, with: model)
    barButtonView?.labelView.text = model.network.details.name
    
    interactor.getImage(for: model.network.imageNetworkURL) { [weak self] image in
      guard let self else {
        return
      }
      barButtonView?.iconLeftView.image = image
    }
  }
}

// MARK: - SendPaymentScreenInteractorOutput

extension SendPaymentScreenPresenter: SendPaymentScreenInteractorOutput {}

// MARK: - SendPaymentScreenFactoryOutput

extension SendPaymentScreenPresenter: SendPaymentScreenFactoryOutput {}

// MARK: - SceneViewModel

extension SendPaymentScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var isEndEditing: Bool {
    true
  }
  
  var leftBarButtonItem: SKBarButtonItem? {
    .init(.close(action: { [weak self] in
      self?.moduleOutput?.closeSendPaymentScreenButtonTapped()
    }))
  }
  
  var centerBarButtonItem: SKBarButtonViewType? {
    .widgetCryptoView(barButtonView)
  }
  
  var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
    return .always
  }
}

// MARK: - Private

private extension SendPaymentScreenPresenter {
  func setupSKBarButtonView() {
    barButtonView = SKBarButtonView(
      .init(
        leftImage: nil,
        centerText: stateScreenModel.tokenModel.network.details.name,
        rightImage: stateScreenModel.screenType == .openFromMainScreen ?
        UIImage(systemName: "chevron.down")?.withTintColor(SKStyleAsset.ghost.color, renderingMode: .alwaysTemplate) :
          nil,
        isEnabled: stateScreenModel.screenType == .openFromMainScreen,
        action: { [weak self] in
          guard let self else {
            return
          }
          self.moduleOutput?.openNetworkTokensScreen(self.stateScreenModel.tokenModel)
        }
      )
    )
    
    interactor.getImage(for: stateScreenModel.tokenModel.network.imageNetworkURL) { [weak self] image in
      guard let self else {
        return
      }
      
      barButtonView?.iconLeftView.image = image
    }
  }
}

// MARK: - Constants

private enum Constants {}
