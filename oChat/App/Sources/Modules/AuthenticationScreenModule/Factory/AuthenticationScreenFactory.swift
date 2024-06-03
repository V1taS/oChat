//
//  AuthenticationScreenFactory.swift
//  oChat
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
        return oChatStrings.AuthenticationScreenLocalization
          .State.EnterPasscode.title
      default:
        return oChatStrings.AuthenticationScreenLocalization
          .State.ReEnterPasscode.title
      }
    case .loginPasscode:
      let title = oChatStrings.AuthenticationScreenLocalization
        .State.LoginPasscode.title
      return title
    case let .changePasscode(result):
      switch result {
      case .enterOldPasscode:
        return oChatStrings.AuthenticationScreenLocalization
          .State.EnterOldPasscode.title
      case .enterNewPasscode:
        return oChatStrings.AuthenticationScreenLocalization
          .State.EnterPasscode.title
      case .reEnterNewPasscode:
        return oChatStrings.AuthenticationScreenLocalization
          .State.ReEnterPasscode.title
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
        oChatStrings.AuthenticationScreenLocalization
          .State.CreatePasscode.Success.title :
        oChatStrings.AuthenticationScreenLocalization
          .State.CreatePasscode.Failure.title
        return (isValidation: isValidation, helperText: isValidationText)
      }
    case .loginPasscode:
      let isValidation = accessCode == oldAccessCode
      let isValidationText: String? = isValidation ?
      oChatStrings.AuthenticationScreenLocalization
        .State.LoginPasscode.Success.title :
      oChatStrings.AuthenticationScreenLocalization
        .State.LoginPasscode.Failure.title
      return (isValidation: isValidation, helperText: isValidationText)
    case let .changePasscode(result):
      switch result {
      case .enterOldPasscode:
        let isValidation = oldAccessCode == confirmAccessCode
        let isValidationText: String? = isValidation ?
        oChatStrings.AuthenticationScreenLocalization
          .State.LoginPasscode.Success.title :
        oChatStrings.AuthenticationScreenLocalization
          .State.LoginPasscode.Failure.title
        return (isValidation: isValidation, helperText: isValidationText)
      case .enterNewPasscode:
        return isValidationCode(accessCode, maxDigitsAccessCode: maxDigitsAccessCode)
      case .reEnterNewPasscode:
        let isValidation = accessCode == confirmAccessCode
        let isValidationText: String? = isValidation ?
        oChatStrings.AuthenticationScreenLocalization
          .State.CreatePasscode.Success.title :
        oChatStrings.AuthenticationScreenLocalization
          .State.CreatePasscode.Failure.title
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
        helperText: oChatStrings.AuthenticationScreenLocalization.State
          .ValidationCount.Failure.title("\(maxDigitsAccessCode)")
      )
    }
    
    let simplePasswords = Constants.simplePasswords
    if simplePasswords.contains(accessCode) {
      return (
        isValidation: false,
        helperText: oChatStrings.AuthenticationScreenLocalization.State
          .SimplePasswords.Failure.title
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
