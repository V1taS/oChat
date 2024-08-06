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

  @Published var statePasswordWidgetModels: [WidgetCryptoView.Model] = []
  @Published var stateSecurityWidgetModels: [WidgetCryptoView.Model] = []
  
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
  @MainActor
  func updateScreen() async {
    let appSettingsModel = await interactor.getAppSettingsModel()
    statePasswordWidgetModels = factory.createPasswordWidgetModels(appSettingsModel)
    stateSecurityWidgetModels = factory.createSecurityWidgetModels(appSettingsModel)
  }
  
  func successAuthorizationPasswordDisable() async {
    await interactor.resetPasscode()
    await interactor.resetFakePasscode()
    await updateScreen()
  }
  
  func successFakeAuthorizationPasswordDisable() async {
    await interactor.resetFakePasscode()
    await updateScreen()
  }
}

// MARK: - PasscodeSettingsScreenInteractorOutput

extension PasscodeSettingsScreenPresenter: PasscodeSettingsScreenInteractorOutput {}

// MARK: - PasscodeSettingsScreenFactoryOutput

extension PasscodeSettingsScreenPresenter: PasscodeSettingsScreenFactoryOutput {
  @MainActor
  func openSetAccessCode(_ isNewAccessCode: Bool) async {
    if isNewAccessCode {
      moduleOutput?.openNewAccessCode()
    } else {
      moduleOutput?.openAuthorizationPasswordDisable()
    }
    
    await updateScreen()
  }
  
  func openChangeAccessCode() {
    moduleOutput?.openChangeAccessCode()
  }
  
  func openFakeChangeAccessCode() async {
    await moduleOutput?.openFakeChangeAccessCode()
  }
  
  @MainActor
  func openFakeSetAccessCode(_ isNewFakeCode: Bool) async {
    guard await interactor.getAppSettingsModel().appPassword != nil else {
      interactor.showNotification(
        .negative(
          title: "Необходимо  сначала включить основной пароль"
        )
      )
      await updateScreen()
      return
    }
    
    if isNewFakeCode {
      await moduleOutput?.openFakeSetAccessCode()
    } else {
      moduleOutput?.openFakeAuthorizationPasswordDisable()
    }
  }
  
  func setTypingIndicator(_ value: Bool) async {
    await interactor.setIsTypingIndicatorEnabled(value)
    await updateScreen()
  }
  
  func setCanSaveMedia(_ value: Bool) async {
    await interactor.setCanSaveMedia(value)
    await updateScreen()
  }
  
  func setChatHistoryStored(_ value: Bool) async {
    await interactor.setIsChatHistoryStored(value)
    await updateScreen()
  }
  
  func setVoiceChanger(_ value: Bool) async {
    await interactor.setIsVoiceChangerEnabled(value)
    await updateScreen()
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
