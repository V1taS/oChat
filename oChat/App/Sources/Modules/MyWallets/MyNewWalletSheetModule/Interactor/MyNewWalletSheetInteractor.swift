//
//  MyNewWalletSheetInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI

/// События которые отправляем из Interactor в Presenter
protocol MyNewWalletSheetInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol MyNewWalletSheetInteractorInput {}

/// Интерактор
final class MyNewWalletSheetInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MyNewWalletSheetInteractorOutput?
}

// MARK: - MyNewWalletSheetInteractorInput

extension MyNewWalletSheetInteractor: MyNewWalletSheetInteractorInput {}

// MARK: - Private

private extension MyNewWalletSheetInteractor {}

// MARK: - Constants

private enum Constants {}
