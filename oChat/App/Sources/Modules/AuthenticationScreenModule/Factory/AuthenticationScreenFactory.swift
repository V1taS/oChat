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
  func createPasscodeTitle(
    _ state: AuthenticationScreenState,
    flowType: AuthenticationScreenFlowType
  ) -> String
  
  /// Валидация кода доступа
  func createValidationPasscode(
    _ state: AuthenticationScreenState,
    accessCode: String,
    confirmAccessCode: String,
    maxDigitsAccessCode: Int,
    oldAccessCode: String?,
    fakeAccessCode: String?,
    flowType: AuthenticationScreenFlowType,
    maxCountAttempts: Int,
    currentAttempts: Int
  ) -> (isValidation: Bool, helperText: String?)
}

/// Фабрика
final class AuthenticationScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: AuthenticationScreenFactoryOutput?
}

// MARK: - AuthenticationScreenFactoryInput

extension AuthenticationScreenFactory: AuthenticationScreenFactoryInput {
  func createPasscodeTitle(
    _ state: AuthenticationScreenState,
    flowType: AuthenticationScreenFlowType
  ) -> String {
    switch state {
    case let .createPasscode(result):
      switch result {
      case .enterPasscode:
        switch flowType {
        case .mainFlow, .all:
          return OChatStrings.AuthenticationScreenLocalization.State
            .EnterPasscode.title
        case .fakeFlow:
          return OChatStrings.AuthenticationScreenLocalization.State
            .EnterFakePasscode.title
        }
      default:
        switch flowType {
        case .mainFlow, .all:
          return OChatStrings.AuthenticationScreenLocalization.State
            .ReEnterPasscode.title
        case .fakeFlow:
          return OChatStrings.AuthenticationScreenLocalization.State
            .ReEnterFakePasscode.title
        }
      }
    case .loginPasscode:
      let title = OChatStrings.AuthenticationScreenLocalization.State
        .LoginPasscode.title
      return title
    case let .changePasscode(result):
      switch flowType {
      case .mainFlow, .all:
        switch result {
        case .enterOldPasscode:
          return OChatStrings.AuthenticationScreenLocalization.State
            .EnterOldPasscode.title
        case .enterNewPasscode:
          return OChatStrings.AuthenticationScreenLocalization.State
            .EnterPasscode.title
        case .reEnterNewPasscode:
          return OChatStrings.AuthenticationScreenLocalization.State
            .ReEnterPasscode.title
        }
      case .fakeFlow:
        switch result {
        case .enterOldPasscode:
          return OChatStrings.AuthenticationScreenLocalization.State
            .EnterFakeOldPasscode.title
        case .enterNewPasscode:
          return OChatStrings.AuthenticationScreenLocalization.State
            .EnterFakePasscode.title
        case .reEnterNewPasscode:
          return OChatStrings.AuthenticationScreenLocalization.State
            .ReEnterFakePasscode.title
        }
      }
    }
  }
  
  func createValidationPasscode(
    _ state: AuthenticationScreenState,
    accessCode: String,
    confirmAccessCode: String,
    maxDigitsAccessCode: Int,
    oldAccessCode: String?,
    fakeAccessCode: String?,
    flowType: AuthenticationScreenFlowType,
    maxCountAttempts: Int,
    currentAttempts: Int
  ) -> (isValidation: Bool, helperText: String?) {
    switch state {
    case let .createPasscode(result):
      switch result {
      case .enterPasscode:
        return isValidationCode(accessCode, maxDigitsAccessCode: maxDigitsAccessCode, flowType: flowType)
      default:
        let isValidation = accessCode == confirmAccessCode
        let isValidationText: String? = isValidation ?
        OChatStrings.AuthenticationScreenLocalization.State
          .CreatePasscode.Success.title :
        OChatStrings.AuthenticationScreenLocalization.State
          .CreatePasscode.Failure.title
        return (isValidation: isValidation, helperText: isValidationText)
      }
    case .loginPasscode:
      var isValidation = false
      switch flowType {
      case .mainFlow:
        isValidation = accessCode == oldAccessCode
      case .fakeFlow:
        isValidation = accessCode == fakeAccessCode
      case .all:
        isValidation = accessCode == oldAccessCode || accessCode == fakeAccessCode
      }
      
      var isValidationText: String? = isValidation ?
      OChatStrings.AuthenticationScreenLocalization.State
        .LoginPasscode.Success.title :
      OChatStrings.AuthenticationScreenLocalization.State
        .LoginPasscode.Failure.title
      
      if !isValidation {
        if currentAttempts == maxCountAttempts {
          isValidationText = OChatStrings.AuthenticationScreenLocalization.State
            .LoginPasscode.AllDataErased.title
        } else if currentAttempts > 2 {
          isValidationText = OChatStrings.AuthenticationScreenLocalizable
            .attemptsCount(maxCountAttempts - currentAttempts)
        }
      }
      return (isValidation: isValidation, helperText: isValidationText)
    case let .changePasscode(result):
      switch result {
      case .enterOldPasscode:
        var isValidation = false
        switch flowType {
        case .mainFlow:
          isValidation = oldAccessCode == confirmAccessCode
        case .fakeFlow:
          isValidation = fakeAccessCode == confirmAccessCode
        case .all:
          isValidation = oldAccessCode == confirmAccessCode || fakeAccessCode == confirmAccessCode
        }
        
        let isValidationText: String? = isValidation ?
        OChatStrings.AuthenticationScreenLocalization.State
          .LoginPasscode.Success.title :
        OChatStrings.AuthenticationScreenLocalization.State
          .LoginPasscode.Failure.title
        return (isValidation: isValidation, helperText: isValidationText)
      case .enterNewPasscode:
        return isValidationCode(accessCode, maxDigitsAccessCode: maxDigitsAccessCode, flowType: flowType)
      case .reEnterNewPasscode:
        let isValidation = accessCode == confirmAccessCode
        let isValidationText: String? = isValidation ?
        OChatStrings.AuthenticationScreenLocalization.State
          .CreatePasscode.Success.title :
        OChatStrings.AuthenticationScreenLocalization.State
          .CreatePasscode.Failure.title
        return (isValidation: isValidation, helperText: isValidationText)
      }
    }
  }
}

// MARK: - Private

private extension AuthenticationScreenFactory {
  func isValidationCode(
    _ accessCode: String,
    maxDigitsAccessCode: Int,
    flowType: AuthenticationScreenFlowType
  ) -> (isValidation: Bool, helperText: String?) {
    guard accessCode.count == 4 else {
      return (
        isValidation: false,
        helperText: OChatStrings.AuthenticationScreenLocalization.State
          .ValidationCount.Failure.title("\(maxDigitsAccessCode)")
      )
    }
    
    let simplePasswords = Constants.simplePasswords
    if simplePasswords.contains(accessCode) && flowType != .fakeFlow {
      
      return (
        isValidation: false,
        helperText: OChatStrings.AuthenticationScreenLocalization.State
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
