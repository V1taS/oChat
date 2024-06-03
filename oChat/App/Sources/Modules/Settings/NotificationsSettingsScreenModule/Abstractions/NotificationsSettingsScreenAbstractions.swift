//
//  NotificationsSettingsScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI

/// События которые отправляем из `NotificationsSettingsScreenModule` в `Coordinator`
public protocol NotificationsSettingsScreenModuleOutput: AnyObject {}

/// События которые отправляем из `Coordinator` в `NotificationsSettingsScreenModule`
public protocol NotificationsSettingsScreenModuleInput {

  /// События которые отправляем из `NotificationsSettingsScreenModule` в `Coordinator`
  var moduleOutput: NotificationsSettingsScreenModuleOutput? { get set }
}

/// Готовый модуль `NotificationsSettingsScreenModule`
public typealias NotificationsSettingsScreenModule = (viewController: UIViewController, input: NotificationsSettingsScreenModuleInput)
