//
//  ListSeedPhraseScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions
import SKFoundation

final class ListSeedPhraseScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateIsConfirmationRequirements = false
  @Published var stateContinueButtonTitle = OChatStrings.ListSeedPhraseScreenLocalization.State.Button.Continue.title
  @Published var stateCopyButtonTitle = OChatStrings.ListSeedPhraseScreenLocalization.State.Button.Copy.title
  @Published var stateHeaderTitle = OChatStrings.ListSeedPhraseScreenLocalization.State.Header.title
  @Published var stateHeaderDescription = OChatStrings.ListSeedPhraseScreenLocalization.State.Header.description
  @Published var stateTermsOfAgreementTitle = OChatStrings.ListSeedPhraseScreenLocalization.State.TermsOfAgreement.title
  @Published var stateListSeedPhrase: [String] = []
  @Published var stateScreenType: ListSeedPhraseScreenType
  
  // MARK: - Internal properties
  
  weak var moduleOutput: ListSeedPhraseScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: ListSeedPhraseScreenInteractorInput
  private let factory: ListSeedPhraseScreenFactoryInput
  private let walletModel: WalletModel
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - screenType: Тип экрана
  init(interactor: ListSeedPhraseScreenInteractorInput,
       factory: ListSeedPhraseScreenFactoryInput,
       screenType: ListSeedPhraseScreenType,
       walletModel: WalletModel) {
    self.interactor = interactor
    self.factory = factory
    self.stateScreenType = screenType
    self.walletModel = walletModel
    self.stateListSeedPhrase = walletModel.seedPhrase.wordsArray()
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
  
  func copyListSeedButtonTapped() {
    let seedPhraseString = stateListSeedPhrase.joined(separator: " ")
    interactor.copyToClipboard(text: seedPhraseString) { [weak self] result in
      switch result {
      case .success:
        self?.interactor.showNotification(
          .neutral(
            title: OChatStrings.ListSeedPhraseScreenLocalization.State.Copy.SeedPhrase.success
          )
        )
      case .failure:
        self?.interactor.showNotification(
          .negative(
            title: OChatStrings.ListSeedPhraseScreenLocalization.State.Copy.SeedPhrase.failure
          )
        )
      }
    }
  }
  
  func saveListSeedAndContinueButtonTapped() {
    interactor.saveWallet(walletModel) { [weak self] in
      self?.moduleOutput?.saveListSeedAndContinueButtonTapped()
    }
  }
}

// MARK: - ListSeedPhraseScreenModuleInput

extension ListSeedPhraseScreenPresenter: ListSeedPhraseScreenModuleInput {}

// MARK: - ListSeedPhraseScreenInteractorOutput

extension ListSeedPhraseScreenPresenter: ListSeedPhraseScreenInteractorOutput {}

// MARK: - ListSeedPhraseScreenFactoryOutput

extension ListSeedPhraseScreenPresenter: ListSeedPhraseScreenFactoryOutput {}

// MARK: - SceneViewModel

extension ListSeedPhraseScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    stateHeaderTitle
  }
  
  var leftBarButtonItem: SKBarButtonItem? {
    if stateScreenType == .termsAndConditionsScreen {
      return .init(.close(action: { [weak self] in
        self?.moduleOutput?.closeListSeedScreenButtonTapped()
      }))
    } else {
      return nil
    }
  }
}

// MARK: - Private

private extension ListSeedPhraseScreenPresenter {}

// MARK: - Constants

private enum Constants {}
