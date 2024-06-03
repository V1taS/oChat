//
//  RemoveWalletSheetInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SwiftUI

/// События которые отправляем из Interactor в Presenter
protocol RemoveWalletSheetInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol RemoveWalletSheetInteractorInput {}

/// Интерактор
final class RemoveWalletSheetInteractor {
  
  // MARK: - Internal properties
  
  weak var output: RemoveWalletSheetInteractorOutput?
}

// MARK: - RemoveWalletSheetInteractorInput

extension RemoveWalletSheetInteractor: RemoveWalletSheetInteractorInput {}

// MARK: - Private

private extension RemoveWalletSheetInteractor {}

// MARK: - Constants

private enum Constants {}
