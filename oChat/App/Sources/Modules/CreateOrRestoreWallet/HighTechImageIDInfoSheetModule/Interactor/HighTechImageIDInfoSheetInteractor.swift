//
//  HighTechImageIDInfoSheetInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//

import SwiftUI

/// События которые отправляем из Interactor в Presenter
protocol HighTechImageIDInfoSheetInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol HighTechImageIDInfoSheetInteractorInput {}

/// Интерактор
final class HighTechImageIDInfoSheetInteractor {
  
  // MARK: - Internal properties
  
  weak var output: HighTechImageIDInfoSheetInteractorOutput?
}

// MARK: - HighTechImageIDInfoSheetInteractorInput

extension HighTechImageIDInfoSheetInteractor: HighTechImageIDInfoSheetInteractorInput {}

// MARK: - Private

private extension HighTechImageIDInfoSheetInteractor {}

// MARK: - Constants

private enum Constants {}
