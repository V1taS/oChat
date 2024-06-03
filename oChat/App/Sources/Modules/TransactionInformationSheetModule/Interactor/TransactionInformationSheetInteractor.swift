//
//  TransactionInformationSheetInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 07.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol TransactionInformationSheetInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol TransactionInformationSheetInteractorInput {
  /// Открывает URL в Safari внутри приложения.
  /// - Parameters:
  ///   - urlString: Строка URL для открытия.
  func openURLInSafari(urlString: String)
}

/// Интерактор
final class TransactionInformationSheetInteractor {
  
  // MARK: - Internal properties
  
  weak var output: TransactionInformationSheetInteractorOutput?
  
  // MARK: - Private properties
  
  private let systemService: ISystemService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(services: IApplicationServices) {
    systemService = services.userInterfaceAndExperienceService.systemService
  }
}

// MARK: - TransactionInformationSheetInteractorInput

extension TransactionInformationSheetInteractor: TransactionInformationSheetInteractorInput {
  func openURLInSafari(urlString: String) {
    systemService.openURLInSafari(urlString: urlString)
  }
}

// MARK: - Private

private extension TransactionInformationSheetInteractor {}

// MARK: - Constants

private enum Constants {}
