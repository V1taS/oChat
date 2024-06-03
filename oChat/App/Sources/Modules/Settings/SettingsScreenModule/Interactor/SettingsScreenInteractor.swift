//
//  SettingsScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol SettingsScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol SettingsScreenInteractorInput {
  /// Возвращает текущий язык приложения.
  /// Метод анализирует системные настройки и возвращает один из поддерживаемых языков,
  /// указанных в перечислении `AppLanguageType`.
  /// - Returns: Текущий язык приложения как значение перечисления `AppLanguageType`.
  func getCurrentLanguage() -> AppLanguageType
  
  /// Возвращает количество кошельков.
  /// - Parameter completion: Замыкание, которое принимает количество кошельков.
  func getWalletsCount(completion: ((_ count: Int) -> Void)?)
  
  /// Возвращает текущую валюту.
  /// - Parameter completion: Замыкание, которое принимает модель текущей валюты.
  func getCurrentCurrency(completion: ((_ currencyModel: CurrencyModel) -> Void)?)
  
  /// Возвращает статус включения кода доступа.
  /// - Parameter completion: Замыкание, которое принимает значение `true`, если код доступа включен, и `false`, если отключен.
  func getIsAccessCodeEnabled(completion: ((_ isEnabled: Bool) -> Void)?)
  
  /// Возвращает текущую версию приложения.
  /// - Returns: Строка с версией приложения, например, "1.0".
  func getAppVersion() -> String
}

/// Интерактор
final class SettingsScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: SettingsScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let systemService: ISystemService
  private let modelHandlerService: IModelHandlerService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    systemService = services.userInterfaceAndExperienceService.systemService
    modelHandlerService = services.dataManagementService.modelHandlerService
  }
}

// MARK: - SettingsScreenInteractorInput

extension SettingsScreenInteractor: SettingsScreenInteractorInput {
  func getAppVersion() -> String {
    systemService.getAppVersion()
  }
  
  func getWalletsCount(completion: ((_ count: Int) -> Void)?) {
    modelHandlerService.getWalletModels { wallets in
      completion?(wallets.count)
    }
  }
  
  func getCurrentCurrency(completion: ((_ currencyModel: CurrencyModel) -> Void)?) {
    modelHandlerService.getAppSettingsModel { appSettingsModel in
      completion?(appSettingsModel.currentCurrency)
    }
  }
  
  func getIsAccessCodeEnabled(completion: ((_ isEnabled: Bool) -> Void)?) {
    modelHandlerService.getAppSettingsModel { appSettingsModel in
      completion?(appSettingsModel.appPassword != nil)
    }
  }
  
  func getCurrentLanguage() -> AppLanguageType {
    systemService.getCurrentLanguage()
  }
}

// MARK: - Private

private extension SettingsScreenInteractor {}

// MARK: - Constants

private enum Constants {}
