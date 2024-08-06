//
//  PasscodeSettingsScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI

/// События которые отправляем из `PasscodeSettingsScreenModule` в `Coordinator`
public protocol PasscodeSettingsScreenModuleOutput: AnyObject {
  /// Открыть экран изменения пароля
  func openChangeAccessCode()
  
  /// Открыть экран создания пароля
  func openNewAccessCode()
  
  /// Открыть экран подтверждения отключения пароля
  func openAuthorizationPasswordDisable()
  
  /// Открыть экран подтверждения отключения фейкового пароля
  func openFakeAuthorizationPasswordDisable()
  
  /// Открыть экран изменения фейкового пароля
  func openFakeChangeAccessCode() async
  
  /// Устанавливаем фейковый пароль на вход в приложение
  func openFakeSetAccessCode() async
}

/// События которые отправляем из `Coordinator` в `PasscodeSettingsScreenModule`
public protocol PasscodeSettingsScreenModuleInput {
  /// Отключить пароль
  func successAuthorizationPasswordDisable() async
  
  /// Отключить фейковый пароль
  func successFakeAuthorizationPasswordDisable() async
  
  /// Обновить экран
  func updateScreen() async

  /// События которые отправляем из `PasscodeSettingsScreenModule` в `Coordinator`
  var moduleOutput: PasscodeSettingsScreenModuleOutput? { get set }
}

/// Готовый модуль `PasscodeSettingsScreenModule`
public typealias PasscodeSettingsScreenModule = (viewController: UIViewController, input: PasscodeSettingsScreenModuleInput)
