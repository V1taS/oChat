//
//  ListSeedPhraseScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol ListSeedPhraseScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol ListSeedPhraseScreenFactoryInput {}

/// Фабрика
final class ListSeedPhraseScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: ListSeedPhraseScreenFactoryOutput?
}

// MARK: - ListSeedPhraseScreenFactoryInput

extension ListSeedPhraseScreenFactory: ListSeedPhraseScreenFactoryInput {}

// MARK: - Private

private extension ListSeedPhraseScreenFactory {}

// MARK: - Constants

private enum Constants {}
