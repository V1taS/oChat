//
//  HintBackupScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI

/// События которые отправляем из `HintBackupScreenModule` в `Coordinator`
public protocol HintBackupScreenModuleOutput: AnyObject {
  /// Кнопка продолжить была нажата
  func continueHintBackupButtonTapped()
}

/// События которые отправляем из `Coordinator` в `HintBackupScreenModule`
public protocol HintBackupScreenModuleInput {

  /// События которые отправляем из `HintBackupScreenModule` в `Coordinator`
  var moduleOutput: HintBackupScreenModuleOutput? { get set }
}

/// Готовый модуль `HintBackupScreenModule`
public typealias HintBackupScreenModule = (viewController: UIViewController, input: HintBackupScreenModuleInput)
