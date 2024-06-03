//
//  MyWalletsScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class MyWalletsScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateWidgetCryptoModels: [SKUIKit.WidgetCryptoView.Model] = []
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MyWalletsScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: MyWalletsScreenInteractorInput
  private let factory: MyWalletsScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: MyWalletsScreenInteractorInput,
       factory: MyWalletsScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  lazy var viewWillAppear: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    initialSetup()
  }
  
  // MARK: - Internal func
  
  func getRoundButtonTitle() -> String {
    factory.createRoundButtonTitle()
  }
}

// MARK: - MyWalletsScreenModuleInput

extension MyWalletsScreenPresenter: MyWalletsScreenModuleInput {}

// MARK: - MyWalletsScreenInteractorOutput

extension MyWalletsScreenPresenter: MyWalletsScreenInteractorOutput {}

// MARK: - MyWalletsScreenFactoryOutput

extension MyWalletsScreenPresenter: MyWalletsScreenFactoryOutput {
  func openMyWalletSettingsScreen(_ walletModel: SKAbstractions.WalletModel) {
    moduleOutput?.openMyWalletSettingsScreen(walletModel)
  }
}

// MARK: - SceneViewModel

extension MyWalletsScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
    .always
  }
}

// MARK: - Private

private extension MyWalletsScreenPresenter {
  func initialSetup() {
    interactor.getContent { [weak self] walletModels, currency in
      guard let self else {
        return
      }
      
      stateWidgetCryptoModels = factory.createWidgetWalletsModels(walletModels: walletModels, currency: currency)
    }
  }
}

// MARK: - Constants

private enum Constants {}
