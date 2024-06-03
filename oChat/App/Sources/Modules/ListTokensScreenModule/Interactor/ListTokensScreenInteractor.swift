//
//  ListTokensScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 25.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol ListTokensScreenInteractorOutput: AnyObject {
  /// Был получен список Токенов
  func didReceiveTokens(_ tokens: [TokenModel])
}

/// События которые отправляем от Presenter к Interactor
protocol ListTokensScreenInteractorInput {
  /// Запросить список токенов
  func getListTokens()
}

/// Интерактор
final class ListTokensScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: ListTokensScreenInteractorOutput?
}

// MARK: - ListTokensScreenInteractorInput

extension ListTokensScreenInteractor: ListTokensScreenInteractorInput {
  func getListTokens() {
    let tokens: [TokenModel] = TokenModel.allMocks
    
    output?.didReceiveTokens(tokens)
  }
}

// MARK: - Private

private extension ListTokensScreenInteractor {}

// MARK: - Constants

private enum Constants {}
