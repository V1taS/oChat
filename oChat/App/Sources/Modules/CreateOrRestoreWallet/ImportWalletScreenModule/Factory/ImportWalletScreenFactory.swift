//
//  ImportWalletScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol ImportWalletScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol ImportWalletScreenFactoryInput {
  /// Заголовок экрана
  func createScreenTitle(
    _ walletType: ImportWalletScreenType
  ) -> String
  /// Описание на экране
  func createScreenDescription(
    _ walletType: ImportWalletScreenType
  ) -> String
  /// Заголовок у кнопки
  func createButtonTitle() -> String
}

/// Фабрика
final class ImportWalletScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: ImportWalletScreenFactoryOutput?
}

// MARK: - ImportWalletScreenFactoryInput

extension ImportWalletScreenFactory: ImportWalletScreenFactoryInput {
  func createButtonTitle() -> String {
    return oChatStrings.ImportWalletScreenLocalization
      .State.Button.title
  }
  
  func createScreenTitle(
    _ walletType: ImportWalletScreenType
  ) -> String {
    switch walletType {
    case .seedPhrase:
      return oChatStrings.ImportWalletScreenLocalization
        .State.SeedPhrase.Header.title
    case .trackingWallet:
      return oChatStrings.ImportWalletScreenLocalization
        .State.TrackingWallet.Header.title
    }
  }
  
  func createScreenDescription(
    _ walletType: ImportWalletScreenType
  ) -> String {
    switch walletType {
    case .seedPhrase:
      return oChatStrings.ImportWalletScreenLocalization
        .State.SeedPhrase.description
    case .trackingWallet:
      return oChatStrings.ImportWalletScreenLocalization
        .State.TrackingWallet.description
    }
  }
}

// MARK: - Private

private extension ImportWalletScreenFactory {}

// MARK: - Constants

private enum Constants {}
