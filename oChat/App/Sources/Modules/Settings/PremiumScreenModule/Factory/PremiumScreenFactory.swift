//
//  PremiumScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 15.08.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol PremiumScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol PremiumScreenFactoryInput {}

/// Фабрика
final class PremiumScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: PremiumScreenFactoryOutput?
}

// MARK: - PremiumScreenFactoryInput

extension PremiumScreenFactory: PremiumScreenFactoryInput {}

// MARK: - Private

private extension PremiumScreenFactory {}

// MARK: - Constants

private enum Constants {}
