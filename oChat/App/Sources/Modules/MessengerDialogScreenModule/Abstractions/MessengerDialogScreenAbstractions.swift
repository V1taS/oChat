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
  func messengerDialogWillDisappear() async
  
  /// Пользователь отправил сообщение
  func sendMessage(contact: ContactModel) async
  
  /// Запросить переписку повторно
  func sendInitiateChatFromDialog(contactModel: ContactModel) async
  
  /// Подтвердить запрос на переписку
  func confirmRequestForDialog(contactModel: ContactModel) async
  
  /// Отклонить запрос на переписку
  func cancelRequestForDialog(contactModel: ContactModel) async
  
  /// Удалить сообщение
  func removeMessage(id: String, contact: ContactModel) async
  
  /// Сохраняет `ContactModel` асинхронно.
  /// - Parameters:
  ///   - model: Модель `ContactModel`, которая будутет сохранена.
  func saveContactModel(_ model: ContactModel) async
  
  /// Закрыть экран диалогов
  func closeMessengerDialog() async
  
  /// Метод для установки статуса "печатает" для друга.
  /// - Parameters:
  ///   - isTyping: Статус "печатает" (true, если пользователь печатает).
  ///   - toxPublicKey: Публичный ключ друга
  @discardableResult
  func setUserIsTyping(
    _ isTyping: Bool,
    to toxPublicKey: String
  ) async -> Result<Void, any Error>
  
  /// Метод для отправки push-уведомлений
  func sendPushNotification(contact: ContactModel) async
}

/// События которые отправляем из `Coordinator` в `MessengerDialogScreenModule`
public protocol MessengerDialogScreenModuleInput {
  /// Пользователь отправляет файл
  func handleFileSender(progress: Int, publicToxKey: String)
  
  /// Пользователь получает файл
  func handleFileReceive(progress: Int, publicToxKey: String)
  
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
