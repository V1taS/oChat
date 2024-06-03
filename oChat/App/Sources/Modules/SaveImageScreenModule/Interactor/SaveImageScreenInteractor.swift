//
//  SaveImageScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 22.05.2024.
//

import SwiftUI

/// События которые отправляем из Interactor в Presenter
protocol SaveImageScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol SaveImageScreenInteractorInput {}

/// Интерактор
final class SaveImageScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: SaveImageScreenInteractorOutput?
}

// MARK: - SaveImageScreenInteractorInput

extension SaveImageScreenInteractor: SaveImageScreenInteractorInput {}

// MARK: - Private

private extension SaveImageScreenInteractor {}

// MARK: - Constants

private enum Constants {}
