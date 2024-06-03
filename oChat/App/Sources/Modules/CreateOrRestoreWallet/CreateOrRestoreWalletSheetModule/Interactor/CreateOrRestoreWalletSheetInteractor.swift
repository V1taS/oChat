//
//  CreateOrRestoreWalletSheetInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//

import SwiftUI

/// События которые отправляем из Interactor в Presenter
protocol CreateOrRestoreWalletSheetInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol CreateOrRestoreWalletSheetInteractorInput {}

/// Интерактор
final class CreateOrRestoreWalletSheetInteractor {
  
  // MARK: - Internal properties
  
  weak var output: CreateOrRestoreWalletSheetInteractorOutput?
}

// MARK: - CreateOrRestoreWalletSheetInteractorInput

extension CreateOrRestoreWalletSheetInteractor: CreateOrRestoreWalletSheetInteractorInput {}

// MARK: - Private

private extension CreateOrRestoreWalletSheetInteractor {}

// MARK: - Constants

private enum Constants {}
