//
//  MyWalletCustomizationScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol MyWalletCustomizationScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol MyWalletCustomizationScreenInteractorInput {
  /// Получает модель настроек приложения `AppSettingsModel` асинхронно.
  /// - Parameter completion: Блок завершения, который вызывается с `AppSettingsModel` после завершения операции.
  func getAppSettingsModel(completion: @escaping (AppSettingsModel) -> Void)
  
  /// Устанавливает имя кошелька.
  /// - Parameters:
  ///   - model: Модель кошелька `WalletModel`.
  ///   - name: Новое имя для кошелька.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func setNameWallet(_ model: WalletModel, _ name: String, completion: ((_ model: WalletModel?) -> Void)?)
}

/// Интерактор
final class MyWalletCustomizationScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MyWalletCustomizationScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let modelHandlerService: IModelHandlerService
  private let modelSettingsManager: IModelSettingsManager
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    modelHandlerService = services.dataManagementService.modelHandlerService
    modelSettingsManager = services.dataManagementService.modelSettingsManager
  }
}

// MARK: - MyWalletCustomizationScreenInteractorInput

extension MyWalletCustomizationScreenInteractor: MyWalletCustomizationScreenInteractorInput {
  func setNameWallet(_ model: WalletModel, _ name: String, completion: ((_ model: WalletModel?) -> Void)?) {
    modelSettingsManager.setNameWallet(model, name, completion: completion)
  }
  
  func getAppSettingsModel(completion: @escaping (SKAbstractions.AppSettingsModel) -> Void) {
    modelHandlerService.getAppSettingsModel(completion: completion)
  }
}

// MARK: - Private

private extension MyWalletCustomizationScreenInteractor {}

// MARK: - Constants

private enum Constants {}
