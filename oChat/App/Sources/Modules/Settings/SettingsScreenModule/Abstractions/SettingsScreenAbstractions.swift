//
//  SettingsScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI

/// События которые отправляем из `SettingsScreenModule` в `Coordinator`
public protocol SettingsScreenModuleOutput: AnyObject {
  /// Открыть экран настроек по безопасности
  func openPasscodeAndFaceIDSection()
  /// Открыть экран настроек уведомлений
  func openNotificationsSection()
  /// Открыть экран настроек внешнего вида
  func openAppearanceSection()
  /// Открыть экран настроек языка
  func openLanguageSection()
  /// Открыть секцию с профилем
  func openMyProfileSection()
}

/// События которые отправляем из `Coordinator` в `SettingsScreenModule`
public protocol SettingsScreenModuleInput {

  /// События которые отправляем из `SettingsScreenModule` в `Coordinator`
  var moduleOutput: SettingsScreenModuleOutput? { get set }
}

/// Готовый модуль `SettingsScreenModule`
public typealias SettingsScreenModule = (viewController: UIViewController, input: SettingsScreenModuleInput)
