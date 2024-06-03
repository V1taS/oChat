//
//  MessengerNewMessengeScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol MessengerNewMessengeScreenFactoryOutput: AnyObject {
  func openNewMessageDialogScreen(messageModel: MessengerDialogModel.MessengeModel)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol MessengerNewMessengeScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Получить имя отправителя
  func getSenderName() -> String
  /// Получить стоимость отправки смс
  func getCostOfSendingMessage() -> String
}

/// Фабрика
final class MessengerNewMessengeScreenFactory {
  // MARK: - Internal properties
  private let senderName: String
  private let costOfSendingMessage: String

  weak var output: MessengerNewMessengeScreenFactoryOutput?

  init(senderName: String, costOfSendingMessage: String) {
    self.senderName = senderName
    self.costOfSendingMessage = costOfSendingMessage
  }
}

// MARK: - MessengerNewMessengeScreenFactoryInput

extension MessengerNewMessengeScreenFactory: MessengerNewMessengeScreenFactoryInput {
  func createHeaderTitle() -> String {
    return "Новое сообщение"
  }

  func getSenderName() -> String {
    senderName
  }

  func getCostOfSendingMessage() -> String {
    costOfSendingMessage
  }
}

// MARK: - Private

private extension MessengerNewMessengeScreenFactory {}

// MARK: - Constants

private enum Constants {}
