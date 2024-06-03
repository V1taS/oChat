//
//  MyWalletCustomizationScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class MyWalletCustomizationScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateNewInputText = ""
  @Published var stateOldInputText = ""
  @Published var stateCurrency = ""
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MyWalletCustomizationScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: MyWalletCustomizationScreenInteractorInput
  private let factory: MyWalletCustomizationScreenFactoryInput
  private let walletModel: WalletModel
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - walletModel: Моделька кошелька
  init(interactor: MyWalletCustomizationScreenInteractorInput,
       factory: MyWalletCustomizationScreenFactoryInput,
       _ walletModel: WalletModel) {
    self.interactor = interactor
    self.factory = factory
    self.walletModel = walletModel
    stateNewInputText = walletModel.name ?? ""
    stateOldInputText = walletModel.name ?? ""
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
  
  func getTopInputHelper() -> String {
    factory.getTopInputHelper()
  }
  
  func changeInputText(text: String) {
    stateNewInputText = text
  }
  
  func getWalletName() -> String {
    walletModel.name ?? ""
  }
  
  func getTotalAmount() -> String {
    walletModel.totalTokenBalanceInCurrency.format(formatType: .precise)
  }
  
  func getMainButtonTitle() -> String {
    factory.getMainButtonTitle()
  }
  
  func confirmButtonPressed() {
    interactor.setNameWallet(walletModel, stateNewInputText) { [weak self] model in
      guard let model else {
        return
      }
      self?.moduleOutput?.confirmCustomizationButtonPressed(model)
    }
  }
}

// MARK: - MyWalletCustomizationScreenModuleInput

extension MyWalletCustomizationScreenPresenter: MyWalletCustomizationScreenModuleInput {}

// MARK: - MyWalletCustomizationScreenInteractorOutput

extension MyWalletCustomizationScreenPresenter: MyWalletCustomizationScreenInteractorOutput {}

// MARK: - MyWalletCustomizationScreenFactoryOutput

extension MyWalletCustomizationScreenPresenter: MyWalletCustomizationScreenFactoryOutput {}

// MARK: - SceneViewModel

extension MyWalletCustomizationScreenPresenter: SceneViewModel {
  var isEndEditing: Bool {
    true
  }
}

// MARK: - Private

private extension MyWalletCustomizationScreenPresenter {
  func setupInitialState() {
    interactor.getAppSettingsModel { [weak self] appSettingsModel in
      guard let self else {
        return
      }
      stateCurrency = appSettingsModel.currentCurrency.type.details.symbol
    }
  }
}

// MARK: - Constants

private enum Constants {}
