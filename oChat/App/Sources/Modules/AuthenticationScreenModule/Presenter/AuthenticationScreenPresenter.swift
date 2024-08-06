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
  @Published var stateFakeAccessCode: String?
  @Published var stateMaxDigitsAccessCode = 4
  @Published var stateValidationPasscode: (isValidation: Bool, helperText: String?) = (true, nil)
  @Published var statePasscodeTitle = ""
  
  // MARK: - Internal properties
  
  weak var moduleOutput: AuthenticationScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: AuthenticationScreenInteractorInput
  private let factory: AuthenticationScreenFactoryInput
  private let flowType: AuthenticationScreenFlowType
  
  // Максимальное количество попыток
  private var stateMaxCountAttempts = 5
  private var currentAttempts: Int {
    get {
      UserDefaults.standard.integer(forKey: Constants.attemptsPasscodeKey)
    } set {
      UserDefaults.standard.setValue(newValue, forKey: Constants.attemptsPasscodeKey)
    }
  }
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - state: Состояние экрана
  ///   - flowType: Тип флоу
  init(interactor: AuthenticationScreenInteractorInput,
       factory: AuthenticationScreenFactoryInput,
       state: AuthenticationScreenState,
       flowType: AuthenticationScreenFlowType) {
    self.interactor = interactor
    self.factory = factory
    self.stateCurrentStateScreen = state
    self.flowType = flowType
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else { return }
    if currentAttempts == .zero { currentAttempts = 1 }
    
    getPasscodeTitle()
    
    Task { [weak self] in
      guard let self else { return }
      
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
      oldAccessCode: stateOldAccessCode, 
      fakeAccessCode: stateFakeAccessCode, 
      flowType: flowType,
      maxCountAttempts: stateMaxCountAttempts,
      currentAttempts: currentAttempts
    )
    
    if case .fakeFlow = flowType, stateOldAccessCode == stateAccessCode {
      stateValidationPasscode = (
        isValidation: false,
        helperText: OChatStrings.AuthenticationScreenLocalization.State
          .CreatePasscode.NotAvailable.title
      )
      return
    }
    
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
  
  @MainActor
  func authenticationSuccess() async {
    if stateValidationPasscode.isValidation {
      switch stateCurrentStateScreen {
      case .createPasscode, .changePasscode:
        switch flowType {
        case .mainFlow:
          await interactor.setAppPassword(stateConfirmAccessCode)
          moduleOutput?.authenticationSuccess()
        case .fakeFlow:
          await interactor.setFakeAppPassword(stateConfirmAccessCode)
          moduleOutput?.authenticationSuccess()
        case .all:
          break
        }
      case .loginPasscode:
        switch flowType {
        case .mainFlow:
          await interactor.setAccessType(.main)
          moduleOutput?.authenticationSuccess()
        case .fakeFlow:
          await interactor.setAccessType(.fake)
          moduleOutput?.authenticationFakeSuccess()
        case .all:
          if stateAccessCode == stateFakeAccessCode {
            await interactor.setAccessType(.fake)
            moduleOutput?.authenticationFakeSuccess()
            return
          }
          await interactor.setAccessType(.main)
          moduleOutput?.authenticationSuccess()
        }
      }
    } else if currentAttempts >= stateMaxCountAttempts {
      currentAttempts = 1
      moduleOutput?.allDataErased()
    } else if flowType != .fakeFlow {
      currentAttempts += 1
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
  func getOldAccessCodeForchangePasscodeAndloginPasscode() async {
    stateOldAccessCode = await interactor.getOldAccessCode()
    stateFakeAccessCode = await interactor.getFakeAccessCode()
  }
}

// MARK: - Constants

private enum Constants {
  static let attemptsPasscodeKey = "Authentication_AttemptsPasscode"
}
