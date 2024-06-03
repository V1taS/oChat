//
//  ActivityScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI

/// События которые отправляем из `ActivityScreenModule` в `Coordinator`
public protocol ActivityScreenModuleOutput: AnyObject {
  /// Открыть шторку с подробной информацией по определенной транзакции
  func openActivitySheet()
}

/// События которые отправляем из `Coordinator` в `ActivityScreenModule`
public protocol ActivityScreenModuleInput {

  /// События которые отправляем из `ActivityScreenModule` в `Coordinator`
  var moduleOutput: ActivityScreenModuleOutput? { get set }
}

/// Готовый модуль `ActivityScreenModule`
public typealias ActivityScreenModule = (viewController: UIViewController, input: ActivityScreenModuleInput)
