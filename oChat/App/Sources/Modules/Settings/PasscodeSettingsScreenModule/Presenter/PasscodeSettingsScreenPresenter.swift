//
//  PasscodeSettingsScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class PasscodeSettingsScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateWidgetCryptoModels: [SKUIKit.WidgetCryptoView.Model] = []
  
  // MARK: - Internal properties
  
  weak var moduleOutput: PasscodeSettingsScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: PasscodeSettingsScreenInteractorInput
  private let factory: PasscodeSettingsScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: PasscodeSettingsScreenInteractorInput,
       factory: PasscodeSettingsScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  lazy var viewWillAppear: (() -> Void)? = {
    Task { [weak self] in
      await self?.updateScreen()
    }
  }
  
  // MARK: - Internal func
}

// MARK: - PasscodeSettingsScreenModuleInput

extension PasscodeSettingsScreenPresenter: PasscodeSettingsScreenModuleInput {
  func updateScreen() async {
    let isAppPassword = await interactor.isAppPassword()
    stateWidgetCryptoModels = factory.createWidgetModels(
      stateIsShowChangeAccessCode: isAppPassword
    )
  }
  
  func successAuthorizationPasswordDisable() async {
    await interactor.resetPasscode()
    stateWidgetCryptoModels = factory.createWidgetModels(
      stateIsShowChangeAccessCode: false
    )
  }
}

// MARK: - PasscodeSettingsScreenInteractorOutput

extension PasscodeSettingsScreenPresenter: PasscodeSettingsScreenInteractorOutput {}

// MARK: - PasscodeSettingsScreenFactoryOutput

extension PasscodeSettingsScreenPresenter: PasscodeSettingsScreenFactoryOutput {
  @MainActor
  func changeLockScreenState(_ isLockScreen: Bool) async {
    if isLockScreen {
      moduleOutput?.openNewAccessCode()
    } else {
      moduleOutput?.openAuthorizationPasswordDisable()
    }
    
    let isLockScreen = await interactor.getIsLockScreen()
    
    stateWidgetCryptoModels = factory.createWidgetModels(
      stateIsShowChangeAccessCode: isLockScreen
    )
  }
  
  func openChangeAccessCode() {
    moduleOutput?.openChangeAccessCode()
  }
}

// MARK: - SceneViewModel

extension PasscodeSettingsScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
    .always
  }
}

// MARK: - Private

private extension PasscodeSettingsScreenPresenter {}

// MARK: - Constants

private enum Constants {}
