//
//  HintBackupScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI

/// События которые отправляем из Interactor в Presenter
protocol HintBackupScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol HintBackupScreenInteractorInput {}

/// Интерактор
final class HintBackupScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: HintBackupScreenInteractorOutput?
}

// MARK: - HintBackupScreenInteractorInput

extension HintBackupScreenInteractor: HintBackupScreenInteractorInput {}

// MARK: - Private

private extension HintBackupScreenInteractor {}

// MARK: - Constants

private enum Constants {}
