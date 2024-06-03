//
//  CurrencyListScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol CurrencyListScreenInteractorOutput: AnyObject {
  /// Была получена текущая валюта в приложении
  func didReceiveCurrentCurrency(_ currency: CurrencyModel)
}

/// События которые отправляем от Presenter к Interactor
protocol CurrencyListScreenInteractorInput {
  /// Получить текущую валюту в приложении
  func getCurrentCurrency()
  /// Сохранить текущую валюту в приложении
  func saveCurrentCurrency(_ currency: CurrencyModel)
}

/// Интерактор
final class CurrencyListScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: CurrencyListScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let modelHandlerService: IModelHandlerService
  private let appSettingsManager: IAppSettingsManager
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    modelHandlerService = services.dataManagementService.modelHandlerService
    appSettingsManager = services.dataManagementService.appSettingsManager
  }
}

// MARK: - CurrencyListScreenInteractorInput

extension CurrencyListScreenInteractor: CurrencyListScreenInteractorInput {
  func getCurrentCurrency() {
    modelHandlerService.getAppSettingsModel { [weak self] appSettingsModel in
      self?.output?.didReceiveCurrentCurrency(appSettingsModel.currentCurrency)
    }
  }
  
  func saveCurrentCurrency(_ currency: CurrencyModel) {
    appSettingsManager.setCurrentCurrency(currency) { [weak self] in
      self?.output?.didReceiveCurrentCurrency(currency)
    }
  }
}

// MARK: - Private

private extension CurrencyListScreenInteractor {}

// MARK: - Constants

private enum Constants {}
