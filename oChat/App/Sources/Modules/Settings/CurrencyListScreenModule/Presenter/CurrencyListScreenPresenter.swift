//
//  CurrencyListScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class CurrencyListScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateWidgetCryptoModels: [SKUIKit.WidgetCryptoView.Model] = []
  
  // MARK: - Internal properties
  
  weak var moduleOutput: CurrencyListScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: CurrencyListScreenInteractorInput
  private let factory: CurrencyListScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: CurrencyListScreenInteractorInput,
       factory: CurrencyListScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    interactor.getCurrentCurrency()
  }
  
  // MARK: - Internal func
}

// MARK: - CurrencyListScreenModuleInput

extension CurrencyListScreenPresenter: CurrencyListScreenModuleInput {}

// MARK: - CurrencyListScreenInteractorOutput

extension CurrencyListScreenPresenter: CurrencyListScreenInteractorOutput {
  func didReceiveCurrentCurrency(_ currency: CurrencyModel) {
    stateWidgetCryptoModels = factory.createWidgetModels(currency)
  }
}

// MARK: - CurrencyListScreenFactoryOutput

extension CurrencyListScreenPresenter: CurrencyListScreenFactoryOutput {
  func currentCurrencyTapped(_ currency: CurrencyModel) {
    interactor.saveCurrentCurrency(currency)
  }
}

// MARK: - SceneViewModel

extension CurrencyListScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
    .always
  }
}

// MARK: - Private

private extension CurrencyListScreenPresenter {}

// MARK: - Constants

private enum Constants {}
