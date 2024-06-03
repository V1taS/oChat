//
//  SaveImageScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 22.05.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol SaveImageScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol SaveImageScreenFactoryInput {
  /// Создать описание
  func createHeaderDescription() -> String
  /// Создать заголовок для кнопки сохранить
  func saveButtonTitle() -> String
  /// Создать заголовок
  func createHeaderTitle() -> String
}

/// Фабрика
final class SaveImageScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: SaveImageScreenFactoryOutput?
}

// MARK: - SaveImageScreenFactoryInput

extension SaveImageScreenFactory: SaveImageScreenFactoryInput {
  func createHeaderDescription() -> String {
    OChatStrings.SaveImageScreenLocalization
      .State.Header.description
  }
  
  func saveButtonTitle() -> String {
    OChatStrings.SaveImageScreenLocalization
      .State.Button.title
  }
  
  func createHeaderTitle() -> String {
    OChatStrings.SaveImageScreenLocalization
      .State.Header.title
  }
}

// MARK: - Private

private extension SaveImageScreenFactory {}

// MARK: - Constants

private enum Constants {}
