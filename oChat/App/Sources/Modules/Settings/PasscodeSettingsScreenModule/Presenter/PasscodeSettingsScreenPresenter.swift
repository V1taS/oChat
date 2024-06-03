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
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    updateScreen()
  }
  
  // MARK: - Internal func
}

// MARK: - PasscodeSettingsScreenModuleInput

extension PasscodeSettingsScreenPresenter: PasscodeSettingsScreenModuleInput {
  func updateScreen() {
    interactor.getInitialValue { [weak self] stateFaceID, isShowChangeAccessCode in
      guard let self else {
        return
      }
      
      stateWidgetCryptoModels = factory.createWidgetModels(
        stateFaceID: stateFaceID,
        stateIsShowChangeAccessCode: isShowChangeAccessCode
      )
    }
  }
  
  func successAuthorizationPasswordDisable() {
    interactor.resetPasscode()
    stateWidgetCryptoModels = factory.createWidgetModels(
      stateFaceID: false,
      stateIsShowChangeAccessCode: false
    )
  }
}

// MARK: - PasscodeSettingsScreenInteractorOutput

extension PasscodeSettingsScreenPresenter: PasscodeSettingsScreenInteractorOutput {}

// MARK: - PasscodeSettingsScreenFactoryOutput

extension PasscodeSettingsScreenPresenter: PasscodeSettingsScreenFactoryOutput {
  func changeLockScreenState(_ isLockScreen: Bool) {
    if isLockScreen {
      moduleOutput?.openNewAccessCode()
    } else {
      moduleOutput?.openAuthorizationPasswordDisable()
    }
    
    interactor.getFaceIDState { [weak self] isFaceID in
      guard let self else {
        return
      }
      
      interactor.getIsLockScreen { [weak self] isLockScreen in
        guard let self else {
          return
        }
        
        stateWidgetCryptoModels = factory.createWidgetModels(
          stateFaceID: isFaceID,
          stateIsShowChangeAccessCode: isLockScreen
        )
      }
    }
  }
  
  func changeFaceIDState(_ value: Bool) {
    interactor.requestFaceID { [weak self] granted in
      guard let self else {
        return
      }
      interactor.saveFaceIDState(value)
      
      interactor.getIsLockScreen { [weak self] isLockScreen in
        guard let self else {
          return
        }
        
        stateWidgetCryptoModels = factory.createWidgetModels(
          stateFaceID: value && granted && isLockScreen,
          stateIsShowChangeAccessCode: isLockScreen
        )
      }
    }
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
