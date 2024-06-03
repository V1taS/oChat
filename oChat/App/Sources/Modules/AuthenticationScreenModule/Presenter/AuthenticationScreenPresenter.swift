//
//  AuthenticationScreenPresenter.swift
//  oChat
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
    loginFaceID()
    getOldAccessCodeForchangePasscodeAndloginPasscode()
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
  
  func authenticationSuccess() {
    if stateValidationPasscode.isValidation {
      switch stateCurrentStateScreen {
      case .createPasscode, .changePasscode:
        interactor.setAccessCode(stateConfirmAccessCode) { [weak self] in
          guard let self else {
            return
          }
          moduleOutput?.authenticationSuccess()
        }
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
  func loginFaceID() {
    if case let .loginPasscode(result) = stateCurrentStateScreen, case .loginFaceID = result {
      interactor.getIsFaceIDEnabled { [weak self] isFaceIDEnabled in
        guard let self,
              isFaceIDEnabled else {
          self?.stateCurrentStateScreen = .loginPasscode(.enterPasscode)
          return
        }
        
        interactor.authenticationWithFaceID { [weak self] granted in
          if granted {
            self?.moduleOutput?.authenticationSuccess()
          } else {
            self?.stateCurrentStateScreen = .loginPasscode(.enterPasscode)
          }
        }
      }
    }
  }
  
  func getOldAccessCodeForchangePasscodeAndloginPasscode() {
    interactor.getOldAccessCode { [weak self] code in
      guard let self else {
        return
      }
      stateOldAccessCode = code
    }
  }
}

// MARK: - Constants

private enum Constants {}
