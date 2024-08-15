//
//  PremiumScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 15.08.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol PremiumScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol PremiumScreenInteractorInput {}

/// Интерактор
final class PremiumScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: PremiumScreenInteractorOutput?
  
  // MARK: - Private properties
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {}
}

// MARK: - PremiumScreenInteractorInput

extension PremiumScreenInteractor: PremiumScreenInteractorInput {}

// MARK: - Private

private extension PremiumScreenInteractor {}

// MARK: - Constants

private enum Constants {}
