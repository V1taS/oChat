//
//  CreatePhraseWalletScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class CreatePhraseWalletScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateNewWalletType: CreatePhraseWalletScreenType
  @Published var stateCurrentStateScreen: CreatePhraseWalletScreenState = .generatingWallet
  
  @Published var stateGeneratingWalletAnimationName = OChatAsset.loaderCircle.name
  @Published var stateGeneratingWalletTitle = OChatStrings.CreatePhraseWalletScreenLocalization.State.GeneratingWallet.title
  @Published var stateWalletCreatedAnimationName = OChatAsset.loaderSuccess.name
  @Published var stateWalletCreatedTitle = OChatStrings.CreatePhraseWalletScreenLocalization.State.WalletCreated.title
  
  // MARK: - Internal properties
  
  weak var moduleOutput: CreatePhraseWalletScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: CreatePhraseWalletScreenInteractorInput
  private let factory: CreatePhraseWalletScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - newWalletType: Тип создаваемого кошелька
  init(interactor: CreatePhraseWalletScreenInteractorInput,
       factory: CreatePhraseWalletScreenFactoryInput,
       newWalletType: CreatePhraseWalletScreenType) {
    self.interactor = interactor
    self.factory = factory
    self.stateNewWalletType = newWalletType
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {
    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
      guard let self = self else {
        return
      }
      self.stateCurrentStateScreen = .walletCreated
      
      Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
        guard let self = self else {
          return
        }
        self.createSeedPhrase()
      }
    }
  }
}

// MARK: - CreatePhraseWalletScreenModuleInput

extension CreatePhraseWalletScreenPresenter: CreatePhraseWalletScreenModuleInput {}

// MARK: - CreatePhraseWalletScreenInteractorOutput

extension CreatePhraseWalletScreenPresenter: CreatePhraseWalletScreenInteractorOutput {
  func somethingWentWrong() {
    interactor.showNotification(
      .negative(
        title: OChatStrings.CreatePhraseWalletScreenLocalization
          .State.SomethingWentWrong.title
      )
    )
  }
}

// MARK: - CreatePhraseWalletScreenFactoryOutput

extension CreatePhraseWalletScreenPresenter: CreatePhraseWalletScreenFactoryOutput {}

// MARK: - SceneViewModel

extension CreatePhraseWalletScreenPresenter: SceneViewModel {}

// MARK: - Private

private extension CreatePhraseWalletScreenPresenter {
  func createSeedPhrase() {
    switch stateNewWalletType {
    case .seedPhrase12:
      let seedPhrase12 = interactor.createWallet12Words()
      createWallet(seedPhrase: seedPhrase12, walletType: .seedPhrase12)
    case .seedPhrase24:
      let seedPhrase24 = interactor.createWallet24Words()
      createWallet(seedPhrase: seedPhrase24, walletType: .seedPhrase24)
    case .highTechImageID:
      let seedPhrase24 = interactor.createWallet24Words()
      createWallet(seedPhrase: seedPhrase24, walletType: .highTechImageID(passCode: nil))
    }
  }
  
  func createWallet(seedPhrase: String?, walletType: CreatePhraseWalletScreenType) {
    interactor.createWallet(
      seedPhrase: seedPhrase,
      walletType: walletType) { [weak self] model in
        self?.moduleOutput?.walletSeedPhraseHasBeenCreated(model)
      }
  }
}

// MARK: - Constants

private enum Constants {}
