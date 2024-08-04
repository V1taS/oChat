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
  
  /// Пользователь отправляет файл
  func handleFileSender(progress: Int, publicToxKey: String)
  
  /// Пользователь получает файл
  func handleFileReceive(progress: Int, publicToxKey: String)
  
  /// Предложить удалить контакт
  func suggestToRemoveContact(index: Int) async
  
  /// Заблокировать экран
  func lockScreen() async
  
  /// Установить пароль на приложение
  func setPasswordForApp() async
}

/// События которые отправляем из `Coordinator` в `MessengerListScreenModuleModule`
public protocol MessengerListScreenModuleModuleInput {
  /// Удалить контакт
  func removeContact(index: Int) async
  
  /// Удалить сообщение
  func removeMessage(id: String, contact: ContactModel) async
  
  /// Удаляет модель контакта `ContactModel` асинхронно.
  /// - Parameters:
  ///   - contactModel: Модель `ContactModel`, которая будет удалена.
  func removeContactModels(_ contactModel: ContactModel) async
  
  /// Обновить список контактов
  func updateListContacts() async
  
  /// Отправить запрос на переписку
  func sendInitiateChat(contactModel: ContactModel) async
  
  /// Отправить сообщение контакту
  func sendMessage(contact: ContactModel) async
  
  /// Подтвердить запрос на переписку
  func confirmRequestForDialog(contactModel: ContactModel) async
  
  /// Отклонить запрос на переписку
  func cancelRequestForDialog(contactModel: ContactModel) async
  
  /// Сохраняет `ContactModel` асинхронно.
  /// - Parameters:
  ///   - model: Модель `ContactModel`, которая будутет сохранена.
  func saveContactModel(_ model: ContactModel) async
  
  /// Метод для установки статуса "печатает" для друга.
  /// - Parameters:
  ///   - isTyping: Статус "печатает" (true, если пользователь печатает).
  ///   - toxPublicKey: Публичный ключ друга
  func setUserIsTyping(
    _ isTyping: Bool,
    to toxPublicKey: String
  ) async -> Result<Void, any Error>
  
  /// События которые отправляем из `MessengerListScreenModuleModule` в `Coordinator`
  var moduleOutput: MessengerListScreenModuleOutput? { get set }
  
  /// Метод для отправки push-уведомлений
  func sendPushNotification(contact: ContactModel) async
  
  /// Получить модель со всеми настройками
  func getAppSettingsModel() async -> AppSettingsModel
}

/// Готовый модуль `MessengerListScreenModuleModule`
public typealias MessengerListScreenModuleModule = (viewController: UIViewController,
                                                    input: MessengerListScreenModuleModuleInput)
