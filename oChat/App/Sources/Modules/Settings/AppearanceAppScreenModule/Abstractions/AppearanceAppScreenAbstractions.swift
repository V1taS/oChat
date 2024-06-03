//
//  AppearanceAppScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI

/// События которые отправляем из `AppearanceAppScreenModule` в `Coordinator`
public protocol AppearanceAppScreenModuleOutput: AnyObject {}

/// События которые отправляем из `Coordinator` в `AppearanceAppScreenModule`
public protocol AppearanceAppScreenModuleInput {

  /// События которые отправляем из `AppearanceAppScreenModule` в `Coordinator`
  var moduleOutput: AppearanceAppScreenModuleOutput? { get set }
}

/// Готовый модуль `AppearanceAppScreenModule`
public typealias AppearanceAppScreenModule = (viewController: UIViewController, input: AppearanceAppScreenModuleInput)
