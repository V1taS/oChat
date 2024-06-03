//
//  DetailPaymentScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 05.05.2024.
//

import SwiftUI

/// События которые отправляем из Interactor в Presenter
protocol DetailPaymentScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol DetailPaymentScreenInteractorInput {}

/// Интерактор
final class DetailPaymentScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: DetailPaymentScreenInteractorOutput?
}

// MARK: - DetailPaymentScreenInteractorInput

extension DetailPaymentScreenInteractor: DetailPaymentScreenInteractorInput {}

// MARK: - Private

private extension DetailPaymentScreenInteractor {}

// MARK: - Constants

private enum Constants {}
