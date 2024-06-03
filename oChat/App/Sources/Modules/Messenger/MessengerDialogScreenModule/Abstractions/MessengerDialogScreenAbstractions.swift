//
//  MessengerDialogScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI

/// События которые отправляем из `MessengerDialogScreenModule` в `Coordinator`
public protocol MessengerDialogScreenModuleOutput: AnyObject {}

/// События которые отправляем из `Coordinator` в `MessengerDialogScreenModule`
public protocol MessengerDialogScreenModuleInput {

  /// События которые отправляем из `MessengerDialogScreenModule` в `Coordinator`
  var moduleOutput: MessengerDialogScreenModuleOutput? { get set }
}

/// Готовый модуль `MessengerDialogScreenModule`
public typealias MessengerDialogScreenModule = (viewController: UIViewController, input: MessengerDialogScreenModuleInput)
