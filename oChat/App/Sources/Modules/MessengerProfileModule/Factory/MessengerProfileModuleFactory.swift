//
//  MessengerProfileModuleFactory.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol MessengerProfileModuleFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol MessengerProfileModuleFactoryInput {
  /// Создать Описание для экрана
  func createDescriptionTitle() -> String

  /// Создать заголовок для кнопки копирования
  func createCopyButtonTitle() -> String
}

/// Фабрика
final class MessengerProfileModuleFactory {

  // MARK: - Internal properties

  weak var output: MessengerProfileModuleFactoryOutput?
}

// MARK: - MessengerProfileModuleFactoryInput

extension MessengerProfileModuleFactory: MessengerProfileModuleFactoryInput {
  func createCopyButtonTitle() -> String {
    OChatStrings.MessengerProfileModuleLocalization.Messenger
      .Profile.CopyButton.title
  }
  
  func createDescriptionTitle() -> String {
    OChatStrings.MessengerProfileModuleLocalization.Messenger
      .Profile.description
  }
}

// MARK: - Private

private extension MessengerProfileModuleFactory {}

// MARK: - Constants

private enum Constants {}
