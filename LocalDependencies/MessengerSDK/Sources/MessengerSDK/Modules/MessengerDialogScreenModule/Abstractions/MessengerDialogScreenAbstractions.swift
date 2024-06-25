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
  func sendMessage(contact: ContactModel)
  
  /// Запросить переписку повторно
  func sendInitiateChatFromDialog(contactModel: ContactModel)
  
  /// Подтвердить запрос на переписку
  func confirmRequestForDialog(contactModel: ContactModel)
  
  /// Отклонить запрос на переписку
  func cancelRequestForDialog(contactModel: ContactModel)
  
  /// Удалить сообщение
  func removeMessage(id: String, contact: ContactModel)
  
  /// Сохраняет `ContactModel` асинхронно.
  /// - Parameters:
  ///   - model: Модель `ContactModel`, которая будутет сохранена.
  func saveContactModel(_ model: ContactModel)
  
  /// Закрыть экран диалогов
  func closeMessengerDialog()
  
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
  
  /// Метод для отправки push-уведомлений
  func sendPushNotification(contact: ContactModel)
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
