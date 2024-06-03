//
//  RemoveWalletSheetFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol RemoveWalletSheetFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol RemoveWalletSheetFactoryInput {
  /// Возвращает заголовок для хедера
  /// - Returns: Заголовок хедера в виде строки
  func getHeaderTitle() -> String
  
  /// Возвращает заголовок для первого совета
  /// - Returns: Заголовок первого совета в виде строки
  func getTipsOneTitle() -> String
  
  /// Возвращает заголовок для второго совета
  /// - Returns: Заголовок второго совета в виде строки
  func getTipsTwoTitle() -> String
  
  /// Возвращает заголовок для основной кнопки
  /// - Returns: Заголовок основной кнопки в виде строки
  func getMainButtoTitle() -> String
}

/// Фабрика
final class RemoveWalletSheetFactory {
  
  // MARK: - Internal properties
  
  weak var output: RemoveWalletSheetFactoryOutput?
}

// MARK: - RemoveWalletSheetFactoryInput

extension RemoveWalletSheetFactory: RemoveWalletSheetFactoryInput {
  func getHeaderTitle() -> String {
    OChatStrings.RemoveWalletSheetLocalization
      .State.Header.title
  }
  
  func getTipsOneTitle() -> String {
    OChatStrings.RemoveWalletSheetLocalization
      .State.TipsOne.title
  }
  
  func getTipsTwoTitle() -> String {
    OChatStrings.RemoveWalletSheetLocalization
      .State.TipsTwo.title
  }
  
  func getMainButtoTitle() -> String {
    OChatStrings.RemoveWalletSheetLocalization.State.MainButton.title
  }
}

// MARK: - Private

private extension RemoveWalletSheetFactory {}

// MARK: - Constants

private enum Constants {}
