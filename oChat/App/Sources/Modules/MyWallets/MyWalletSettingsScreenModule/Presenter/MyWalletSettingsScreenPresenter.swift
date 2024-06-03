//
//  MyWalletSettingsScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class MyWalletSettingsScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var statePrimaryWidgetCryptoModels: [SKUIKit.WidgetCryptoView.Model] = []
  @Published var stateSecondaryWidgetCryptoModels: [SKUIKit.WidgetCryptoView.Model] = []
  @Published var stateTertiaryWidgetCryptoModels: [SKUIKit.WidgetCryptoView.Model] = []
  @Published var stateCurrency = ""
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MyWalletSettingsScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: MyWalletSettingsScreenInteractorInput
  private let factory: MyWalletSettingsScreenFactoryInput
  private var walletModel: WalletModel
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - walletModel: Моделька кошелька
  init(interactor: MyWalletSettingsScreenInteractorInput,
       factory: MyWalletSettingsScreenFactoryInput,
       walletModel: WalletModel) {
    self.interactor = interactor
    self.factory = factory
    self.walletModel = walletModel
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  lazy var viewWillAppear: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    
    setupInitialState()
  }
  
  // MARK: - Internal func
  
  func getWalletName() -> String {
    walletModel.name ?? ""
  }
  
  func getTotalAmount() -> String {
    walletModel.totalTokenBalanceInCurrency.format(formatType: .precise)
  }
}

// MARK: - MyWalletSettingsScreenModuleInput

extension MyWalletSettingsScreenPresenter: MyWalletSettingsScreenModuleInput {
  func deleteWallet() {
    interactor.getWalletModels { [weak self] walletModels in
      guard let self else {
        return
      }
      
      if walletModels.count > 1 {
        interactor.deleteWallet(walletModel) { [weak self] in
          self?.moduleOutput?.walletSuccessfullyDeleted()
        }
      } else {
        if interactor.deleteAllData() {
          moduleOutput?.exitTheApplication()
        }
      }
    }
  }
  
  func updateContent(_ walletModel: WalletModel) {
    self.walletModel = walletModel
  }
}

// MARK: - MyWalletSettingsScreenInteractorOutput

extension MyWalletSettingsScreenPresenter: MyWalletSettingsScreenInteractorOutput {}

// MARK: - MyWalletSettingsScreenFactoryOutput

extension MyWalletSettingsScreenPresenter: MyWalletSettingsScreenFactoryOutput {
  func openRecoveryImageIDScreen(_ walletModel: WalletModel) {
    moduleOutput?.openRecoveryImageIDScreen(walletModel)
  }
  
  func openDeleteWalletSheet() {
    moduleOutput?.openDeleteWalletSheet()
  }
  
  func openRecoveryPhraseScreen(_ walletModel: SKAbstractions.WalletModel) {
    moduleOutput?.openRecoveryPhraseScreen(walletModel)
  }
  
  func openRenameWalletScreen(_ walletModel: SKAbstractions.WalletModel) {
    moduleOutput?.openRenameWalletScreen(walletModel)
  }
  
  func onChangeIsPrimary(_ value: Bool) {
    interactor.setIsPrimaryWallet(walletModel, value) { [weak self] in
      guard let self else {
        return
      }
      statePrimaryWidgetCryptoModels = factory.createPrimaryWidgetModels(isPrimary: value)
    }
  }
}

// MARK: - SceneViewModel

extension MyWalletSettingsScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
}

// MARK: - Private

private extension MyWalletSettingsScreenPresenter {
  func setupInitialState() {
    interactor.getAppSettingsModel { [weak self] appSettingsModel in
      guard let self else {
        return
      }
      stateCurrency = appSettingsModel.currentCurrency.type.details.symbol
    }
    
    statePrimaryWidgetCryptoModels = factory.createPrimaryWidgetModels(isPrimary: walletModel.isPrimary)
    stateSecondaryWidgetCryptoModels = factory.createSecondaryWidgetModels(walletModel)
    stateTertiaryWidgetCryptoModels = factory.createTertiaryWidgetModels()
  }
}

// MARK: - Constants

private enum Constants {}
