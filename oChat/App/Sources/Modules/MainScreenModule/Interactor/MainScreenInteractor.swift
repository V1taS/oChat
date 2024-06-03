//
//  MainScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol MainScreenInteractorOutput: AnyObject {
  /// Был получен список Токенов
  func didReceiveTokens(_ tokens: [TokenModel])
}

/// События которые отправляем от Presenter к Interactor
protocol MainScreenInteractorInput {
  /// Запросить список токенов
  func getListTokens()
}

/// Интерактор
final class MainScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MainScreenInteractorOutput?
}

// MARK: - MainScreenInteractorInput

extension MainScreenInteractor: MainScreenInteractorInput {
  func getListTokens() {
    let tokens: [TokenModel] = TokenModel.allMocks
    
    output?.didReceiveTokens(tokens)
  }
}

// MARK: - Private

private extension MainScreenInteractor {}

// MARK: - Constants

private enum Constants {}
