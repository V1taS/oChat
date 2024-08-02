//
//  AuthenticationScreenPresenter.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class AuthenticationScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateCurrentStateScreen: AuthenticationScreenState
  @Published var stateAccessCode = ""
  @Published var stateConfirmAccessCode = ""
  @Published var stateOldAccessCode: String?
  @Published var stateMaxDigitsAccessCode = 4
  @Published var stateValidationPasscode: (isValidation: Bool, helperText: String?) = (true, nil)
  @Published var statePasscodeTitle = ""
  
  // MARK: - Internal properties
  
  weak var moduleOutput: AuthenticationScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: AuthenticationScreenInteractorInput
  private let factory: AuthenticationScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - state: Состояние экрана
  init(interactor: AuthenticationScreenInteractorInput,
       factory: AuthenticationScreenFactoryInput,
       state: AuthenticationScreenState) {
    self.interactor = interactor
    self.factory = factory
    self.stateCurrentStateScreen = state
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    getPasscodeTitle()
    
    Task { [weak self] in
      guard let self else { return }
      
      await loginFaceID()
      await getOldAccessCodeForchangePasscodeAndloginPasscode()
    }
  }
  
  // MARK: - Internal func
  
  func validationPasscode() {
    let validationPasscode = factory.createValidationPasscode(
      stateCurrentStateScreen,
      accessCode: stateAccessCode,
      confirmAccessCode: stateConfirmAccessCode,
      maxDigitsAccessCode: stateMaxDigitsAccessCode,
      oldAccessCode: stateOldAccessCode
    )
    stateValidationPasscode = validationPasscode
  }
  
  func getPasscodeTitle() {
    statePasscodeTitle = factory.createPasscodeTitle(stateCurrentStateScreen)
  }
  
  func setAccessCode(_ code: String) {
    stateAccessCode = code
  }
  
  func setConfirmAccessCode(_ code: String) {
    stateConfirmAccessCode = code
  }
  
  func updateCurrentState(_ state: AuthenticationScreenState) {
    stateCurrentStateScreen = state
  }
  
  func authenticationSuccess() async {
    if stateValidationPasscode.isValidation {
      switch stateCurrentStateScreen {
      case .createPasscode, .changePasscode:
        await interactor.setAppPassword(stateConfirmAccessCode)
        moduleOutput?.authenticationSuccess()
      case .loginPasscode:
        moduleOutput?.authenticationSuccess()
      }
    }
  }
}

// MARK: - AuthenticationScreenModuleInput

extension AuthenticationScreenPresenter: AuthenticationScreenModuleInput {}

// MARK: - AuthenticationScreenInteractorOutput

extension AuthenticationScreenPresenter: AuthenticationScreenInteractorOutput {}

// MARK: - AuthenticationScreenFactoryOutput

extension AuthenticationScreenPresenter: AuthenticationScreenFactoryOutput {}

// MARK: - SceneViewModel

extension AuthenticationScreenPresenter: SceneViewModel {}

// MARK: - Private

private extension AuthenticationScreenPresenter {
  @MainActor
  func loginFaceID() async {
    stateCurrentStateScreen = .loginPasscode(.enterPasscode)
  }
  
  @MainActor
  func getOldAccessCodeForchangePasscodeAndloginPasscode() async {
    stateOldAccessCode = await interactor.getOldAccessCode()
  }
}

// MARK: - Constants

private enum Constants {}
