//
//  AuthenticationScreenFactory.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol AuthenticationScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol AuthenticationScreenFactoryInput {
  /// Создать заголовок текст ввода кода доступа
  func createPasscodeTitle(_ state: AuthenticationScreenState) -> String
  /// Валидация кода доступа
  func createValidationPasscode(
    _ state: AuthenticationScreenState,
    accessCode: String,
    confirmAccessCode: String,
    maxDigitsAccessCode: Int,
    oldAccessCode: String?
  ) -> (isValidation: Bool, helperText: String?)
}

/// Фабрика
final class AuthenticationScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: AuthenticationScreenFactoryOutput?
}

// MARK: - AuthenticationScreenFactoryInput

extension AuthenticationScreenFactory: AuthenticationScreenFactoryInput {
  func createPasscodeTitle(_ state: AuthenticationScreenState) -> String {
    switch state {
    case let .createPasscode(result):
      switch result {
      case .enterPasscode:
        return AuthenticationSDKStrings.AuthenticationScreenLocalization
          .stateEnterPasscodeTitle
      default:
        return AuthenticationSDKStrings.AuthenticationScreenLocalization
          .stateReEnterPasscodeTitle
      }
    case .loginPasscode:
      let title = AuthenticationSDKStrings.AuthenticationScreenLocalization
        .stateLoginPasscodeTitle
      return title
    case let .changePasscode(result):
      switch result {
      case .enterOldPasscode:
        return AuthenticationSDKStrings.AuthenticationScreenLocalization
          .stateEnterOldPasscodeTitle
      case .enterNewPasscode:
        return AuthenticationSDKStrings.AuthenticationScreenLocalization
          .stateEnterPasscodeTitle
      case .reEnterNewPasscode:
        return AuthenticationSDKStrings.AuthenticationScreenLocalization
          .stateReEnterPasscodeTitle
      }
    }
  }
  
  func createValidationPasscode(
    _ state: AuthenticationScreenState,
    accessCode: String,
    confirmAccessCode: String,
    maxDigitsAccessCode: Int,
    oldAccessCode: String?
  ) -> (isValidation: Bool, helperText: String?) {
    switch state {
    case let .createPasscode(result):
      switch result {
      case .enterPasscode:
        return isValidationCode(accessCode, maxDigitsAccessCode: maxDigitsAccessCode)
      default:
        let isValidation = accessCode == confirmAccessCode
        
        let isValidationText: String? = isValidation ?
        AuthenticationSDKStrings.AuthenticationScreenLocalization
          .stateCreatePasscodeSuccessTitle :
        AuthenticationSDKStrings.AuthenticationScreenLocalization
          .stateCreatePasscodeFailureTitle
        return (isValidation: isValidation, helperText: isValidationText)
      }
    case .loginPasscode:
      let isValidation = accessCode == oldAccessCode
      let isValidationText: String? = isValidation ?
      AuthenticationSDKStrings.AuthenticationScreenLocalization
        .stateLoginPasscodeSuccessTitle :
      AuthenticationSDKStrings.AuthenticationScreenLocalization
        .stateLoginPasscodeTitle
      return (isValidation: isValidation, helperText: isValidationText)
    case let .changePasscode(result):
      switch result {
      case .enterOldPasscode:
        let isValidation = oldAccessCode == confirmAccessCode
        let isValidationText: String? = isValidation ?
        AuthenticationSDKStrings.AuthenticationScreenLocalization
          .stateLoginPasscodeSuccessTitle :
        AuthenticationSDKStrings.AuthenticationScreenLocalization
          .stateLoginPasscodeFailureTitle
        return (isValidation: isValidation, helperText: isValidationText)
      case .enterNewPasscode:
        return isValidationCode(accessCode, maxDigitsAccessCode: maxDigitsAccessCode)
      case .reEnterNewPasscode:
        let isValidation = accessCode == confirmAccessCode
        let isValidationText: String? = isValidation ?
        AuthenticationSDKStrings.AuthenticationScreenLocalization
          .stateCreatePasscodeSuccessTitle :
        AuthenticationSDKStrings.AuthenticationScreenLocalization
          .stateCreatePasscodeFailureTitle
        return (isValidation: isValidation, helperText: isValidationText)
      }
    }
  }
}

// MARK: - Private

private extension AuthenticationScreenFactory {
  func isValidationCode(
    _ accessCode: String,
    maxDigitsAccessCode: Int
  ) -> (isValidation: Bool, helperText: String?) {
    
    guard accessCode.count == 4 else {
      return (
        isValidation: false,
        helperText: AuthenticationSDKStrings.ValidationCount
          .Failure.title("\(maxDigitsAccessCode)")
      )
    }
    
    let simplePasswords = Constants.simplePasswords
    if simplePasswords.contains(accessCode) {
      
      return (
        isValidation: false,
        helperText: AuthenticationSDKStrings.AuthenticationScreenLocalization
          .stateSimplePasswordsFailureTitle
      )
    }
    return (isValidation: true, helperText: nil)
  }
}

// MARK: - Constants

private enum Constants {
  static let simplePasswords = ["1111", "1234", "0000", "2222", "3333", "4444",
                                "5555", "6666", "7777", "8888", "9999"]
}
