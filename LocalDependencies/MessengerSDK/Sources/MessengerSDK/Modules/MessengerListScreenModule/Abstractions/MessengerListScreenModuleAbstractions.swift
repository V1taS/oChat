//
//  MessengerListScreenModuleAbstractions.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `MessengerListScreenModuleModule` в `Coordinator`
public protocol MessengerListScreenModuleOutput: AnyObject {
  /// Открыть экран создание нового сообщения
  func openNewMessengeScreen(contactAdress: String?)
  /// Открыть экран с диалогом
  func openMessengerDialogScreen(dialogModel: ContactModel)
  
  /// Модель данных была обновлена
  func dataModelHasBeenUpdated()
}

/// События которые отправляем из `Coordinator` в `MessengerListScreenModuleModule`
public protocol MessengerListScreenModuleModuleInput {
  /// Удалить сообщение у контакта
  func removeMessage(_ message: String?, contact: ContactModel, completion: (() -> Void)?)
  
  /// Обновить список контактов
  func updateListContacts(completion: (() -> Void)?)
  
  /// Удаляет модель контакта `ContactModel` асинхронно.
  /// - Parameters:
  ///   - contactModel: Модель `ContactModel`, которая будет удалена.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции удаления. Может быть `nil`.
  func removeContactModels(_ contactModel: ContactModel, completion: (() -> Void)?)
  
  /// Отправить запрос на переписку
  func sendInitiateChat(onionAddress: String)
  
  /// Отправить сообщение контакту
  func sendMessage(_ message: String, contact: ContactModel)
  
  /// События которые отправляем из `MessengerListScreenModuleModule` в `Coordinator`
  var moduleOutput: MessengerListScreenModuleOutput? { get set }
  
  /// Получить контакт по адресу onion
  func getContactModelsFrom(
    onionAddress: String,
    completion: ((ContactModel?) -> Void)?
  )
}

/// Готовый модуль `MessengerListScreenModuleModule`
public typealias MessengerListScreenModuleModule = (viewController: UIViewController, 
                                                    input: MessengerListScreenModuleModuleInput)
