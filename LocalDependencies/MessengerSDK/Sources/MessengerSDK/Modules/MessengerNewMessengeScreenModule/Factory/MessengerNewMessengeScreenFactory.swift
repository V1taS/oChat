//
//  MessengerNewMessengeScreenFactory.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol MessengerNewMessengeScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol MessengerNewMessengeScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  
  /// Создать новый контакт
  func createNewContact(message: String, onionAddress: String) -> ContactModel
  
  /// Добавить сообщение
  func addMessage(contactModel: ContactModel, message: String, isSelf: Bool) -> ContactModel
}

/// Фабрика
final class MessengerNewMessengeScreenFactory {
  
  weak var output: MessengerNewMessengeScreenFactoryOutput?
}

// MARK: - MessengerNewMessengeScreenFactoryInput

extension MessengerNewMessengeScreenFactory: MessengerNewMessengeScreenFactoryInput {
  func addMessage(contactModel: ContactModel, message: String, isSelf: Bool) -> ContactModel {
    var updatedModel = contactModel
    updatedModel.messenges.append(
      .init(
        messageType: isSelf ? .own : .received,
        messageStatus: .inProgress,
        message: message,
        file: nil
      )
    )
    return updatedModel
  }
  
  func createNewContact(message: String, onionAddress: String) -> ContactModel {
    ContactModel(
      name: nil,
      onionAddress: onionAddress,
      meshAddress: nil,
      messenges: [
        .init(
          messageType: .own,
          messageStatus: .inProgress,
          message: message,
          file: nil
        )
      ],
      status: .requested,
      encryptionPublicKey: nil,
      isPasswordDialogProtected: false
    )
  }
  
  func createHeaderTitle() -> String {
    return "Новое сообщение"
  }
}

// MARK: - Private

private extension MessengerNewMessengeScreenFactory {}

// MARK: - Constants

private enum Constants {}
