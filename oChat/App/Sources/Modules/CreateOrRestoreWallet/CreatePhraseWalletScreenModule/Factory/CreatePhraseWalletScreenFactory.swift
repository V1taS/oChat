//
//  CreatePhraseWalletScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol CreatePhraseWalletScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol CreatePhraseWalletScreenFactoryInput {}

/// Фабрика
final class CreatePhraseWalletScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: CreatePhraseWalletScreenFactoryOutput?
}

// MARK: - CreatePhraseWalletScreenFactoryInput

extension CreatePhraseWalletScreenFactory: CreatePhraseWalletScreenFactoryInput {}

// MARK: - Private

private extension CreatePhraseWalletScreenFactory {}

// MARK: - Constants

private enum Constants {}
