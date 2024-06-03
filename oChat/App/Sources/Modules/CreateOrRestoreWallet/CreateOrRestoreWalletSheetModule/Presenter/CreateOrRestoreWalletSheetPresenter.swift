//
//  CreateOrRestoreWalletSheetPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class CreateOrRestoreWalletSheetPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var widgetModels: [CreateOrRestoreWalletSheetModel] = []
  
  // MARK: - Internal properties
  
  weak var moduleOutput: CreateOrRestoreWalletSheetModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: CreateOrRestoreWalletSheetInteractorInput
  private let factory: CreateOrRestoreWalletSheetFactoryInput
  private let sheetType: CreateOrRestoreWalletSheetType
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - sheetType: Тип шторки
  init(interactor: CreateOrRestoreWalletSheetInteractorInput,
       factory: CreateOrRestoreWalletSheetFactoryInput,
       sheetType: CreateOrRestoreWalletSheetType) {
    self.interactor = interactor
    self.factory = factory
    self.sheetType = sheetType
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    widgetModels = factory.createViewModel(with: sheetType)
  }
}

// MARK: - CreateOrRestoreWalletSheetModuleInput

extension CreateOrRestoreWalletSheetPresenter: CreateOrRestoreWalletSheetModuleInput {}

// MARK: - CreateOrRestoreWalletSheetInteractorOutput

extension CreateOrRestoreWalletSheetPresenter: CreateOrRestoreWalletSheetInteractorOutput {}

// MARK: - CreateOrRestoreWalletSheetFactoryOutput

extension CreateOrRestoreWalletSheetPresenter: CreateOrRestoreWalletSheetFactoryOutput {
  func createStandartSeedPhrase12WalletButtonTapped() {
    moduleOutput?.createStandartSeedPhrase12WalletButtonTapped()
  }
  
  func createIndestructibleSeedPhrase24WalletButtonTapped() {
    moduleOutput?.createIndestructibleSeedPhrase24WalletButtonTapped()
  }
  
  func createHighTechImageIDWalletButtonTapped() {
    moduleOutput?.createHighTechImageIDWalletButtonTapped()
  }
  
  func restoreWalletButtonTapped() {
    moduleOutput?.restoreWalletButtonTapped()
  }
  
  func restoreHighTechImageIDWalletButtonTapped() {
    moduleOutput?.restoreHighTechImageIDWalletButtonTapped()
  }
  
  func restoreWalletForObserverButtonTapped() {
    moduleOutput?.restoreWalletForObserverButtonTapped()
  }
}

// MARK: - SceneViewModel

extension CreateOrRestoreWalletSheetPresenter: SceneViewModel {
  var backgroundColor: UIColor? {
    SKStyleAsset.sheet.color
  }
}

// MARK: - Private

private extension CreateOrRestoreWalletSheetPresenter {}

// MARK: - Constants

private enum Constants {}
