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
  /// Экран диалога был закрыт
  func messengerDialogWillDisappear()
  
  /// Пользователь отправил сообщение
  func sendMessage(_ message: String, contact: ContactModel)
  
  /// Запросить переписку повторно
  func sendInitiateChatFromDialog(contactModel: ContactModel)
  
  /// Подтвердить запрос на переписку
  func confirmRequestForDialog(contactModel: ContactModel)
  
  /// Отклонить запрос на переписку
  func cancelRequestForDialog(contactModel: ContactModel)
  
  /// Удалить сообщение
  func removeMessage(id: String, contact: ContactModel)
}

/// События которые отправляем из `Coordinator` в `MessengerDialogScreenModule`
public protocol MessengerDialogScreenModuleInput {
  /// Обновить список контактов
  func updateDialog()
  
  /// События которые отправляем из `MessengerDialogScreenModule` в `Coordinator`
  var moduleOutput: MessengerDialogScreenModuleOutput? { get set }
}

/// Готовый модуль `MessengerDialogScreenModule`
public typealias MessengerDialogScreenModule = (
  viewController: UIViewController,
  input: MessengerDialogScreenModuleInput
)
