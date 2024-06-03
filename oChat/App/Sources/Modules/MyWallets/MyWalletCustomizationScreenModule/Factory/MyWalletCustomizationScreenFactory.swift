//
//  MyWalletCustomizationScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol MyWalletCustomizationScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol MyWalletCustomizationScreenFactoryInput {
  /// Получить текст для верхней подсказки
  /// - Returns: Строка с текстом верхней подсказки
  func getTopInputHelper() -> String
  
  /// Получить название главной кнопки
  /// - Returns: Строка с названием главной кнопки
  func getMainButtonTitle() -> String
}

/// Фабрика
final class MyWalletCustomizationScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: MyWalletCustomizationScreenFactoryOutput?
}

// MARK: - MyWalletCustomizationScreenFactoryInput

extension MyWalletCustomizationScreenFactory: MyWalletCustomizationScreenFactoryInput {
  func getTopInputHelper() -> String {
    OChatStrings.MyWalletCustomizationScreenLocalization
      .State.TopInputHelper.title
  }
  
  func getMainButtonTitle() -> String {
    OChatStrings.MyWalletCustomizationScreenLocalization
      .State.MainButton.title
  }
}

// MARK: - Private

private extension MyWalletCustomizationScreenFactory {}

// MARK: - Constants

private enum Constants {}
