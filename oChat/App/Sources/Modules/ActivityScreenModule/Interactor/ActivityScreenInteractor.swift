//
//  ActivityScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI

/// События которые отправляем из Interactor в Presenter
protocol ActivityScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol ActivityScreenInteractorInput {}

/// Интерактор
final class ActivityScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: ActivityScreenInteractorOutput?
}

// MARK: - ActivityScreenInteractorInput

extension ActivityScreenInteractor: ActivityScreenInteractorInput {}

// MARK: - Private

private extension ActivityScreenInteractor {}

// MARK: - Constants

private enum Constants {}
