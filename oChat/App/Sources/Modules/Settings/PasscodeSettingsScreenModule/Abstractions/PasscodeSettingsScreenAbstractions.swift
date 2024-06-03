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
}

/// События которые отправляем из `Coordinator` в `PasscodeSettingsScreenModule`
public protocol PasscodeSettingsScreenModuleInput {
  /// Отключить пароль
  func successAuthorizationPasswordDisable()
  /// Обновить экран
  func updateScreen()

  /// События которые отправляем из `PasscodeSettingsScreenModule` в `Coordinator`
  var moduleOutput: PasscodeSettingsScreenModuleOutput? { get set }
}

/// Готовый модуль `PasscodeSettingsScreenModule`
public typealias PasscodeSettingsScreenModule = (viewController: UIViewController, input: PasscodeSettingsScreenModuleInput)
