//
//  AuthenticationScreenView.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct AuthenticationScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: AuthenticationScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    createEnterPasscodeView()
  }
}

// MARK: - Private

private extension AuthenticationScreenView {
  func createEnterPasscodeView() -> some View {
    return PasscodeScreenView(
      title: presenter.statePasscodeTitle,
      maxDigits: presenter.stateMaxDigitsAccessCode,
      passcodeHandler: { completion in
        completion(
          presenter.stateValidationPasscode.isValidation,
          presenter.stateValidationPasscode.helperText, {
            switch presenter.stateCurrentStateScreen {
            case let .createPasscode(result):
              switch result {
              case .enterPasscode:
                if presenter.stateValidationPasscode.isValidation {
                  presenter.updateCurrentState(.createPasscode(.reEnterPasscode))
                } else {
                  presenter.setAccessCode("")
                }
              case .reEnterPasscode:
                if presenter.stateValidationPasscode.isValidation {
                  Task {
                    await presenter.authenticationSuccess()
                  }
                } else {
                  presenter.setConfirmAccessCode("")
                }
              }
            case let .loginPasscode(result):
              switch result {
              case .enterPasscode:
                Task {
                  await presenter.authenticationSuccess()
                }
              case .loginFaceID:
                break
              }
            case let .changePasscode(result):
              switch result {
              case .enterOldPasscode:
                if presenter.stateValidationPasscode.isValidation {
                  presenter.updateCurrentState(.changePasscode(.enterNewPasscode))
                } else {
                  presenter.setAccessCode("")
                }
              case .enterNewPasscode:
                if presenter.stateValidationPasscode.isValidation {
                  presenter.updateCurrentState(.changePasscode(.reEnterNewPasscode))
                } else {
                  presenter.setAccessCode("")
                }
              case .reEnterNewPasscode:
                if presenter.stateValidationPasscode.isValidation {
                  Task {
                    await presenter.authenticationSuccess()
                  }
                } else {
                  presenter.setConfirmAccessCode("")
                }
              }
            }
          }
        )
      },
      onChangeAccessCode: { code in
        switch presenter.stateCurrentStateScreen {
        case let .createPasscode(result):
          switch result {
          case .enterPasscode:
            presenter.setAccessCode(code)
          case .reEnterPasscode:
            presenter.setConfirmAccessCode(code)
          }
        case let .loginPasscode(result):
          switch result {
          case .enterPasscode:
            presenter.setAccessCode(code)
          case .loginFaceID:
            break
          }
        case let .changePasscode(result):
          switch result {
          case .enterOldPasscode:
            presenter.setConfirmAccessCode(code)
          case .enterNewPasscode:
            presenter.setAccessCode(code)
          case .reEnterNewPasscode:
            presenter.setConfirmAccessCode(code)
          }
        }
        
        presenter.validationPasscode()
        presenter.getPasscodeTitle()
      }
    )
  }
}

// MARK: - Preview

struct AuthenticationScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      AuthenticationScreenAssembly().createModule(
        ApplicationServicesStub(),
        .createPasscode(.enterPasscode)
      ).viewController
    }
  }
}
