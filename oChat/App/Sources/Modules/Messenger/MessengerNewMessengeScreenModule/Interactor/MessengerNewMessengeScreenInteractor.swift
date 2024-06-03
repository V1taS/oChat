//
//  MessengerNewMessengeScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI

/// События которые отправляем из Interactor в Presenter
protocol MessengerNewMessengeScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol MessengerNewMessengeScreenInteractorInput {}

/// Интерактор
final class MessengerNewMessengeScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MessengerNewMessengeScreenInteractorOutput?
}

// MARK: - MessengerNewMessengeScreenInteractorInput

extension MessengerNewMessengeScreenInteractor: MessengerNewMessengeScreenInteractorInput {}

// MARK: - Private

private extension MessengerNewMessengeScreenInteractor {}

// MARK: - Constants

private enum Constants {}
