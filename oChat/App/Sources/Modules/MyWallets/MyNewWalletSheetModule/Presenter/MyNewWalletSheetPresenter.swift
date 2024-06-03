//
//  MyNewWalletSheetPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class MyNewWalletSheetPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateButtonTitle = ""
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MyNewWalletSheetModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: MyNewWalletSheetInteractorInput
  private let factory: MyNewWalletSheetFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: MyNewWalletSheetInteractorInput,
       factory: MyNewWalletSheetFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
  
  func getSeedPhrase12Model() -> MyNewWalletSheetModel {
    factory.createSeedPhrase12Model()
  }
  
  func getSeedPhrase24Model() -> MyNewWalletSheetModel {
    factory.createSeedPhrase24Model()
  }
  
  func getImageHighTechModel() -> MyNewWalletSheetModel {
    factory.createImageHighTechModel()
  }
  
  func getImportSeedPhraseWalletModel() -> MyNewWalletSheetModel {
    factory.createImportSeedPhraseWalletModel()
  }
  
  func getImportImageHighTechWalletModel() -> MyNewWalletSheetModel {
    factory.createImportImageHighTechWalletModel()
  }
  
  func getNewWalletHeaderTitle() -> String {
    factory.getNewWalletHeaderTitle()
  }
  
  func getImportWalletHeaderTitle() -> String {
    factory.getImportWalletHeaderTitle()
  }
  
  // TODO: - Добавлю позже этот функционал
//  func getTrackWalletModel() -> MyNewWalletSheetModel {
//    factory.createTrackWalletModel()
//  }
}

// MARK: - MyNewWalletSheetModuleInput

extension MyNewWalletSheetPresenter: MyNewWalletSheetModuleInput {}

// MARK: - MyNewWalletSheetInteractorOutput

extension MyNewWalletSheetPresenter: MyNewWalletSheetInteractorOutput {}

// MARK: - MyNewWalletSheetFactoryOutput

extension MyNewWalletSheetPresenter: MyNewWalletSheetFactoryOutput {}

// MARK: - SceneViewModel

extension MyNewWalletSheetPresenter: SceneViewModel {
  var backgroundColor: UIColor? {
    SKStyleAsset.sheet.color
  }
}

// MARK: - Private

private extension MyNewWalletSheetPresenter {}

// MARK: - Constants

private enum Constants {}
