//
//  MessengerListScreenModuleAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI

/// События которые отправляем из `MessengerListScreenModuleModule` в `Coordinator`
public protocol MessengerListScreenModuleModuleOutput: AnyObject {
  /// Открыть экран создание нового сообщения
  func openNewMessengeScreen()
  /// Открыть экран с диалогом
  func openMessengerDialogScreen(dialogModel: MessengerDialogModel)
}

/// События которые отправляем из `Coordinator` в `MessengerListScreenModuleModule`
public protocol MessengerListScreenModuleModuleInput {
  func updateList(dialogModel: MessengerDialogModel)
  /// События которые отправляем из `MessengerListScreenModuleModule` в `Coordinator`
  var moduleOutput: MessengerListScreenModuleModuleOutput? { get set }
}

/// Готовый модуль `MessengerListScreenModuleModule`
public typealias MessengerListScreenModuleModule = (viewController: UIViewController, input: MessengerListScreenModuleModuleInput)
