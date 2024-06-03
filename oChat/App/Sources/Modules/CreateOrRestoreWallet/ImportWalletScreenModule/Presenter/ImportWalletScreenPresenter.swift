//
//  ImportWalletScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class ImportWalletScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateWalletType: ImportWalletScreenType
  @Published var statePhraseInputText = ""
  @Published var stateIsValidation = false
  @Published var stateValidationhelperText: String?
  
  // MARK: - Internal properties
  
  weak var moduleOutput: ImportWalletScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: ImportWalletScreenInteractorInput
  private let factory: ImportWalletScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - walletType: Тип восстановления кошелька
  init(interactor: ImportWalletScreenInteractorInput,
       factory: ImportWalletScreenFactoryInput,
       _ walletType: ImportWalletScreenType) {
    self.interactor = interactor
    self.factory = factory
    self.stateWalletType = walletType
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
  
  func getScreenDescription() -> String {
    factory.createScreenDescription(stateWalletType)
  }
  
  func getButtonTitle() -> String {
    factory.createButtonTitle()
  }
  
  func onTextFieldChange(_ text: String) {
    statePhraseInputText = text
    
    if text.count != .zero {
      let validationSeedPhrase = interactor.validationSeedPhrase(text)
      stateIsValidation = validationSeedPhrase.isValidation
      stateValidationhelperText = validationSeedPhrase.helperText
    }
  }
  
  func checkingTheImportedWallet() {
    interactor.checkingTheImportedWallet(stateWalletType, statePhraseInputText)
  }
}

// MARK: - ImportWalletScreenModuleInput

extension ImportWalletScreenPresenter: ImportWalletScreenModuleInput {}

// MARK: - ImportWalletScreenInteractorOutput

extension ImportWalletScreenPresenter: ImportWalletScreenInteractorOutput {
  func walletImportedSuccessfully() {
    moduleOutput?.successImportWalletScreen()
  }
  
  func somethingWentWrong() {
    interactor.showNotification(
      .negative(
        title: oChatStrings.ImportWalletScreenLocalization
          .State.Notification.SomethingWentWrong.title
      )
    )
  }
}

// MARK: - ImportWalletScreenFactoryOutput

extension ImportWalletScreenPresenter: ImportWalletScreenFactoryOutput {}

// MARK: - SceneViewModel

extension ImportWalletScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createScreenTitle(stateWalletType)
  }
  
  var leftBarButtonItem: SKBarButtonItem? {
    .init(.close(action: { [weak self] in
      self?.moduleOutput?.closeImportWalletScreenButtonTapped()
    }))
  }
  
  var isEndEditing: Bool {
    true
  }
}

// MARK: - Private

private extension ImportWalletScreenPresenter {}

// MARK: - Constants

private enum Constants {}
