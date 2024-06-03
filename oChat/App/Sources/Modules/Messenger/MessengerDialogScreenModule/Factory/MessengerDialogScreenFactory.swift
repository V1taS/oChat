//
//  MessengerDialogScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit

/// Cобытия которые отправляем из Factory в Presenter
protocol MessengerDialogScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol MessengerDialogScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle(dialogModel: MessengerDialogModel) -> String
  /// Создать placeholder для input
  func createPlaceholder() -> String
}

/// Фабрика
final class MessengerDialogScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: MessengerDialogScreenFactoryOutput?
}

// MARK: - MessengerDialogScreenFactoryInput

extension MessengerDialogScreenFactory: MessengerDialogScreenFactoryInput {
  func createPlaceholder() -> String {
    return "Message"
  }
  
  func createHeaderTitle(dialogModel: MessengerDialogModel) -> String {
    dialogModel.recipientName.formatString(minTextLength: 20)
  }
}

// MARK: - Private

private extension MessengerDialogScreenFactory {}

// MARK: - Constants

private enum Constants {}
