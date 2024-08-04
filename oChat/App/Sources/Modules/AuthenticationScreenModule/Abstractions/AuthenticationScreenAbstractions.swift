//
//  AuthenticationScreenAbstractions.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI

/// События которые отправляем из `AuthenticationScreenModule` в `Coordinator`
public protocol AuthenticationScreenModuleOutput: AnyObject {
  /// Успешная аунтификация
  func authenticationSuccess()
  
  /// Успешная фейковая аунтификация
  func authenticationFakeSuccess()
}

/// События которые отправляем из `Coordinator` в `AuthenticationScreenModule`
public protocol AuthenticationScreenModuleInput {

  /// События которые отправляем из `AuthenticationScreenModule` в `Coordinator`
  var moduleOutput: AuthenticationScreenModuleOutput? { get set }
}

/// Готовый модуль `AuthenticationScreenModule`
public typealias AuthenticationScreenModule = (viewController: UIViewController, input: AuthenticationScreenModuleInput)
