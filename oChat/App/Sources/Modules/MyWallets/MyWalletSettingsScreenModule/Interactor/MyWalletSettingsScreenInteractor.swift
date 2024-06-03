//
//  MyWalletSettingsScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol MyWalletSettingsScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol MyWalletSettingsScreenInteractorInput {
  /// Получает модель настроек приложения `AppSettingsModel` асинхронно.
  /// - Parameter completion: Блок завершения, который вызывается с `AppSettingsModel` после завершения операции.
  func getAppSettingsModel(completion: @escaping (AppSettingsModel) -> Void)
  
  /// Устанавливает, является ли кошелек основным.
  /// - Parameters:
  ///   - model: Модель кошелька `WalletModel`.
  ///   - value: Значение, указывающее, является ли кошелек основным (`true`) или нет (`false`).
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func setIsPrimaryWallet(_ model: WalletModel, _ value: Bool, completion: (() -> Void)?)
  
  /// Удалить все данные из основной модели
  @discardableResult
  func deleteAllData() -> Bool
  
  /// Получает массив моделей кошельков `WalletModel` асинхронно.
  /// - Parameter completion: Блок завершения, который вызывается с массивом `WalletModel` после завершения операции.
  func getWalletModels(completion: @escaping ([WalletModel]) -> Void)
  
  /// Удаляет кошелек.
  /// - Parameters:
  ///   - model: Модель кошелька `WalletModel`, которую нужно удалить.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func deleteWallet(_ model: WalletModel, completion: (() -> Void)?)
}

/// Интерактор
final class MyWalletSettingsScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MyWalletSettingsScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let modelHandlerService: IModelHandlerService
  private let modelSettingsManager: any IModelSettingsManager
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(_ services: IApplicationServices) {
    modelHandlerService = services.dataManagementService.modelHandlerService
    modelSettingsManager = services.dataManagementService.modelSettingsManager
  }
}

// MARK: - MyWalletSettingsScreenInteractorInput

extension MyWalletSettingsScreenInteractor: MyWalletSettingsScreenInteractorInput {
  func deleteWallet(_ model: WalletModel, completion: (() -> Void)?) {
    modelSettingsManager.deleteWallet(model, completion: completion)
  }
  
  func getWalletModels(completion: @escaping ([SKAbstractions.WalletModel]) -> Void) {
    modelHandlerService.getWalletModels(completion: completion)
  }
  
  func deleteAllData() -> Bool {
    modelHandlerService.deleteAllData()
  }
  
  func setIsPrimaryWallet(_ model: WalletModel, _ value: Bool, completion: (() -> Void)?) {
    modelSettingsManager.setIsPrimaryWallet(model, value, completion: completion)
  }
  
  func getAppSettingsModel(completion: @escaping (SKAbstractions.AppSettingsModel) -> Void) {
    modelHandlerService.getAppSettingsModel(completion: completion)
  }
}

// MARK: - Private

private extension MyWalletSettingsScreenInteractor {}

// MARK: - Constants

private enum Constants {}
