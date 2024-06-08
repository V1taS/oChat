//
//  MessengerDialogScreenAbstractions.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `MessengerDialogScreenModule` в `Coordinator`
public protocol MessengerDialogScreenModuleOutput: AnyObject {
  /// Удалить контакт
  func deleteContactButtonTapped()
  
  /// Контакт был удален
  func contactHasBeenDeleted(_ contactModel: ContactModel)
  
  /// Экран диалога был закрыт
  func messengerDialogWillDisappear()
  
  /// Пользователь отправил сообщение
  func sendMessage(_ message: String, contact: ContactModel)
  
  /// Запросить переписку повторно
  func sendInitiateChatFromDialog(onionAddress: String)
  
  /// Удалить сообщение у контакта
  func removeDialogMessage(_ message: String?, contact: ContactModel, completion: (() -> Void)?)
}

/// События которые отправляем из `Coordinator` в `MessengerDialogScreenModule`
public protocol MessengerDialogScreenModuleInput {
  /// Пользователь выбрал удалить контакт
  func userChoseToDeleteContact()
  
  /// Обновить список контактов
  func updateDialog()

  /// События которые отправляем из `MessengerDialogScreenModule` в `Coordinator`
  var moduleOutput: MessengerDialogScreenModuleOutput? { get set }
}

/// Готовый модуль `MessengerDialogScreenModule`
public typealias MessengerDialogScreenModule = (viewController: UIViewController, input: MessengerDialogScreenModuleInput)
