//
//  MainScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class MainScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateTotalWalletAmount = "$ 1 000 000"
  @Published var stateIsSecure = false
  @Published var stateCryptoCurrencyList: [WidgetCryptoView.Model] = []
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MainScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: MainScreenInteractorInput
  private let factory: MainScreenFactoryInput
  private var cacheTokens: [SKAbstractions.TokenModel] = []
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: MainScreenInteractorInput,
       factory: MainScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  lazy var viewWillAppear: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    interactor.getListTokens()
    stateCryptoCurrencyList = factory.createCryptoCurrencyList(cacheTokens)
  }
  
  // MARK: - Internal func
  
  func refreshable() {
#warning("TODO: - Обновляем табличку")
  }
  
  func getSendButtonTitle() -> String {
    factory.createSendButtonTitle()
  }
  
  func getReceiveButtonTitle() -> String {
    factory.createReceiveButtonTitle()
  }
}

// MARK: - MainScreenModuleInput

extension MainScreenPresenter: MainScreenModuleInput {
  func updateTokens(_ tokenModels: [SKAbstractions.TokenModel]) {
    cacheTokens = tokenModels
  }
}

// MARK: - MainScreenInteractorOutput

extension MainScreenPresenter: MainScreenInteractorOutput {
  func didReceiveTokens(_ tokens: [SKAbstractions.TokenModel]) {
    cacheTokens = tokens
    stateCryptoCurrencyList = factory.createCryptoCurrencyList(tokens)
  }
}

// MARK: - MainScreenFactoryOutput

extension MainScreenPresenter: MainScreenFactoryOutput {
  func openDetailCoinScreen(_ model: SKAbstractions.TokenModel) {
    moduleOutput?.openDetailCoinScreen(model)
  }
  
  func openAddTokenScreen() {
    moduleOutput?.openAddTokenScreen(tokenModels: cacheTokens)
  }
}

// MARK: - SceneViewModel

extension MainScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
}

// MARK: - Private

private extension MainScreenPresenter {}

// MARK: - Constants

private enum Constants {}
