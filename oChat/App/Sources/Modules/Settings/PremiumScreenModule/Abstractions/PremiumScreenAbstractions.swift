//
//  PremiumScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 15.08.2024.
//

import SwiftUI

/// События которые отправляем из `PremiumScreenModule` в `Coordinator`
public protocol PremiumScreenModuleOutput: AnyObject {}

/// События которые отправляем из `Coordinator` в `PremiumScreenModule`
public protocol PremiumScreenModuleInput {

  /// События которые отправляем из `PremiumScreenModule` в `Coordinator`
  var moduleOutput: PremiumScreenModuleOutput? { get set }
}

/// Готовый модуль `PremiumScreenModule`
public typealias PremiumScreenModule = (viewController: UIViewController, input: PremiumScreenModuleInput)
