//
//  AuthenticationScreenState.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation

// MARK: - AuthenticationScreenState

public enum AuthenticationScreenState: Equatable {
  
  /// Создать пароль
  case createPasscode(CreatePasscodeFlow)
  
  /// Изменить пароль
  case changePasscode(ChangePasscodeFlow)
  
  /// Войти по паролю
  case loginPasscode(LoginPasscodeFlow)
}

// MARK: - CreatePasscodeFlow

extension AuthenticationScreenState {
  /// Сценарий создания пароля
  public enum CreatePasscodeFlow: Equatable {
    
    /// Введите пароль
    case enterPasscode
    
    /// Повторите пароль
    case reEnterPasscode
  }
}

// MARK: - CreatePasscodeFlow

extension AuthenticationScreenState {
  /// Сценарий изменения пароля
  public enum ChangePasscodeFlow: Equatable {
    
    /// Введите текущий пароль пароль
    case enterOldPasscode
    
    /// Введите новый пароль
    case enterNewPasscode
    
    /// Повторите новый пароль
    case reEnterNewPasscode
  }
}

// MARK: - CreatePasscodeFlow

extension AuthenticationScreenState {
  /// Сценарий входа в приложение
  public enum LoginPasscodeFlow: Equatable {
    /// Ввойти по FaceID
    case loginFaceID
    
    /// Введите пароль
    case enterPasscode
  }
}
