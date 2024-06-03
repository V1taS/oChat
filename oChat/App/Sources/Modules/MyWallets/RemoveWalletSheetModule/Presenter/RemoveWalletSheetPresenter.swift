//
//  RemoveWalletSheetPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class RemoveWalletSheetPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateButtonTitle = ""
  
  // MARK: - Internal properties
  
  weak var moduleOutput: RemoveWalletSheetModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: RemoveWalletSheetInteractorInput
  private let factory: RemoveWalletSheetFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: RemoveWalletSheetInteractorInput,
       factory: RemoveWalletSheetFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
  
  func getHeaderTitle() -> String {
    factory.getHeaderTitle()
  }
  
  func getTipsOneTitle() -> String {
    factory.getTipsOneTitle()
  }
  
  func getTipsTwoTitle() -> String {
    factory.getTipsTwoTitle()
  }
  
  func getMainButtoTitle() -> String {
    factory.getMainButtoTitle()
  }
}

// MARK: - RemoveWalletSheetModuleInput

extension RemoveWalletSheetPresenter: RemoveWalletSheetModuleInput {}

// MARK: - RemoveWalletSheetInteractorOutput

extension RemoveWalletSheetPresenter: RemoveWalletSheetInteractorOutput {}

// MARK: - RemoveWalletSheetFactoryOutput

extension RemoveWalletSheetPresenter: RemoveWalletSheetFactoryOutput {}

// MARK: - SceneViewModel

extension RemoveWalletSheetPresenter: SceneViewModel {
  var backgroundColor: UIColor? {
    SKStyleAsset.sheet.color
  }
}

// MARK: - Private

private extension RemoveWalletSheetPresenter {}

// MARK: - Constants

private enum Constants {}
