//
//  InitialScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class InitialScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  /// Заголовок кнопки `Создать новый кошелек`
  @Published
  var stateContinueButtonTitle = "Продолжить"
  
  /// Заголовок кнопки `Добавить существующий кошелек`
  @Published
  var stateImportWalletButtonTitle = OChatStrings.InitialScreenLocalization.State.ImportWalletButton.title
  
  // MARK: - Internal properties
  
  weak var moduleOutput: InitialScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: InitialScreenInteractorInput
  private let factory: InitialScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: InitialScreenInteractorInput,
       factory: InitialScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
}

// MARK: - InitialScreenModuleInput

extension InitialScreenPresenter: InitialScreenModuleInput {}

// MARK: - InitialScreenInteractorOutput

extension InitialScreenPresenter: InitialScreenInteractorOutput {}

// MARK: - InitialScreenFactoryOutput

extension InitialScreenPresenter: InitialScreenFactoryOutput {}

// MARK: - SceneViewModel

extension InitialScreenPresenter: SceneViewModel {}

// MARK: - Private

private extension InitialScreenPresenter {}

// MARK: - Constants

private enum Constants {}
