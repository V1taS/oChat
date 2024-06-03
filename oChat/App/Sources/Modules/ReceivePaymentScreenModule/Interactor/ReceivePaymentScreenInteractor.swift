//
//  ReceivePaymentScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol ReceivePaymentScreenInteractorOutput: AnyObject {
  /// Была получена модель с токенов
  func didReceiveTokenModel(_ model: TokenModel)
}

/// События которые отправляем от Presenter к Interactor
protocol ReceivePaymentScreenInteractorInput {
  /// Получить модель с токеном
  func getTokenModel()
}

/// Интерактор
final class ReceivePaymentScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: ReceivePaymentScreenInteractorOutput?
}

// MARK: - ReceivePaymentScreenInteractorInput

extension ReceivePaymentScreenInteractor: ReceivePaymentScreenInteractorInput {
  func getTokenModel() {
    let tokenModel: TokenModel = .binanceMock
    output?.didReceiveTokenModel(tokenModel)
  }
}

// MARK: - Private

private extension ReceivePaymentScreenInteractor {}

// MARK: - Constants

private enum Constants {}
