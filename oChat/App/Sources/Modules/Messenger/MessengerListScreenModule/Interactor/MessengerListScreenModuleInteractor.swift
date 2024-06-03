//
//  MessengerListScreenModuleInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI

/// События которые отправляем из Interactor в Presenter
protocol MessengerListScreenModuleInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol MessengerListScreenModuleInteractorInput {}

/// Интерактор
final class MessengerListScreenModuleInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MessengerListScreenModuleInteractorOutput?
}

// MARK: - MessengerListScreenModuleInteractorInput

extension MessengerListScreenModuleInteractor: MessengerListScreenModuleInteractorInput {}

// MARK: - Private

private extension MessengerListScreenModuleInteractor {}

// MARK: - Constants

private enum Constants {}
