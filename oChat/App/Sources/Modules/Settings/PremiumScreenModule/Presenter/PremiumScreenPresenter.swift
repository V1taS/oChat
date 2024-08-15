//
//  PremiumScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 15.08.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class PremiumScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateButtonTitle = "Продолжить"
  
  // MARK: - Internal properties
  
  weak var moduleOutput: PremiumScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: PremiumScreenInteractorInput
  private let factory: PremiumScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: PremiumScreenInteractorInput,
       factory: PremiumScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
}

// MARK: - PremiumScreenModuleInput

extension PremiumScreenPresenter: PremiumScreenModuleInput {}

// MARK: - PremiumScreenInteractorOutput

extension PremiumScreenPresenter: PremiumScreenInteractorOutput {}

// MARK: - PremiumScreenFactoryOutput

extension PremiumScreenPresenter: PremiumScreenFactoryOutput {}

// MARK: - SceneViewModel

extension PremiumScreenPresenter: SceneViewModel {}

// MARK: - Private

private extension PremiumScreenPresenter {}

// MARK: - Constants

private enum Constants {}
