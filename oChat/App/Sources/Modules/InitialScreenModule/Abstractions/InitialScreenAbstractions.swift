//
//  InitialScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//

import SwiftUI

/// События которые отправляем из `InitialScreenModule` в `Coordinator`
public protocol InitialScreenModuleOutput: AnyObject {
  /// Была нажата кнопка "Создать новый кошелек"
  func continueButtonTapped()
}

/// События которые отправляем из `Coordinator` в `InitialScreenModule`
public protocol InitialScreenModuleInput {

  /// События которые отправляем из `InitialScreenModule` в `Coordinator`
  var moduleOutput: InitialScreenModuleOutput? { get set }
}

/// Готовый модуль `InitialScreenModule`
public typealias InitialScreenModule = (viewController: UIViewController, input: InitialScreenModuleInput)
