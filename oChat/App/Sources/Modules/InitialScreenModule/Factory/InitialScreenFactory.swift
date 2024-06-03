//
//  InitialScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol InitialScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol InitialScreenFactoryInput {}

/// Фабрика
final class InitialScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: InitialScreenFactoryOutput?
}

// MARK: - InitialScreenFactoryInput

extension InitialScreenFactory: InitialScreenFactoryInput {}

// MARK: - Private

private extension InitialScreenFactory {}

// MARK: - Constants

private enum Constants {}
