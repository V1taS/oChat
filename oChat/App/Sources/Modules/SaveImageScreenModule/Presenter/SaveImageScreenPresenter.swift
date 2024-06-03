//
//  SaveImageScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 22.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class SaveImageScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateImageID: Data?
  
  // MARK: - Internal properties
  
  weak var moduleOutput: SaveImageScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: SaveImageScreenInteractorInput
  private let factory: SaveImageScreenFactoryInput
  private let walletModel: WalletModel
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - walletModel: Модель кошелька
  init(interactor: SaveImageScreenInteractorInput,
       factory: SaveImageScreenFactoryInput,
       _ walletModel: WalletModel) {
    self.interactor = interactor
    self.factory = factory
    self.walletModel = walletModel
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    if case let .highTechImageID(imageData) = walletModel.walletType {
      stateImageID = imageData
    }
  }
  
  // MARK: - Internal func
  
  func createHeaderDescription() -> String {
    factory.createHeaderDescription()
  }
  
  func saveButtonTitle() -> String {
    factory.saveButtonTitle()
  }
  
  func saveImageIDButtonTapped() {
    moduleOutput?.saveImageIDButtonTapped(stateImageID)
  }
}

// MARK: - SaveImageScreenModuleInput

extension SaveImageScreenPresenter: SaveImageScreenModuleInput {}

// MARK: - SaveImageScreenInteractorOutput

extension SaveImageScreenPresenter: SaveImageScreenInteractorOutput {}

// MARK: - SaveImageScreenFactoryOutput

extension SaveImageScreenPresenter: SaveImageScreenFactoryOutput {}

// MARK: - SceneViewModel

extension SaveImageScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
}

// MARK: - Private

private extension SaveImageScreenPresenter {}

// MARK: - Constants

private enum Constants {}
