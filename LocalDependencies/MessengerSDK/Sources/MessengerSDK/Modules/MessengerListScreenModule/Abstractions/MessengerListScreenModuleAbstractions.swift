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
  
  /// Открыть панель подключения
  func openPanelConnection()
  
  /// Был сделан скриншот
  func userDidScreenshot()
}

/// События которые отправляем из `Coordinator` в `MessengerListScreenModuleModule`
public protocol MessengerListScreenModuleModuleInput {
  /// Удалить сообщение
  func removeMessage(id: String, contact: ContactModel)
  
  /// Удаляет модель контакта `ContactModel` асинхронно.
  /// - Parameters:
  ///   - contactModel: Модель `ContactModel`, которая будет удалена.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции удаления. Может быть `nil`.
  func removeContactModels(_ contactModel: ContactModel, completion: (() -> Void)?)
  
  /// Обновить список контактов
  func updateListContacts(completion: (() -> Void)?)
  
  /// Отправить запрос на переписку
  func sendInitiateChat(contactModel: ContactModel)
  
  /// Отправить сообщение контакту
  func sendMessage(contact: ContactModel, completion: (() -> Void)?)
  
  /// Подтвердить запрос на переписку
  func confirmRequestForDialog(contactModel: ContactModel)
  
  /// Отклонить запрос на переписку
  func cancelRequestForDialog(contactModel: ContactModel)
  
  /// Сохраняет `ContactModel` асинхронно.
  /// - Parameters:
  ///   - model: Модель `ContactModel`, которая будутет сохранена.
  func saveContactModel(_ model: ContactModel)
  
  /// Метод для установки статуса "печатает" для друга.
  /// - Parameters:
  ///   - isTyping: Статус "печатает" (true, если пользователь печатает).
  ///   - toxPublicKey: Публичный ключ друга
  ///   - completion: Замыкание, вызываемое по завершении операции, с результатом успешного выполнения или ошибкой.
  func setUserIsTyping(
    _ isTyping: Bool,
    to toxPublicKey: String,
    completion: @escaping (Result<Void, Error>) -> Void
  )
  
  /// Повторить отправку сообщения
  func retrySendMessage(messengeModel: MessengeModel, contactModel: ContactModel)
  
  /// События которые отправляем из `MessengerListScreenModuleModule` в `Coordinator`
  var moduleOutput: MessengerListScreenModuleOutput? { get set }
}

/// Готовый модуль `MessengerListScreenModuleModule`
public typealias MessengerListScreenModuleModule = (viewController: UIViewController, 
                                                    input: MessengerListScreenModuleModuleInput)
