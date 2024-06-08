//
//  TorConnectScreenFactory.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 07.06.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol TorConnectScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol TorConnectScreenFactoryInput {}

/// Фабрика
final class TorConnectScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: TorConnectScreenFactoryOutput?
}

// MARK: - TorConnectScreenFactoryInput

extension TorConnectScreenFactory: TorConnectScreenFactoryInput {}

// MARK: - Private

private extension TorConnectScreenFactory {}

// MARK: - Constants

private enum Constants {}
