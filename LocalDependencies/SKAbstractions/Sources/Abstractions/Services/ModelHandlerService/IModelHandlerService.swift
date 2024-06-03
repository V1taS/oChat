//
//  IModelHandlerService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 18.05.2024.
//

import Foundation

/// Протокол `IModelHandlerService` предназначен для обработки и управления моделями данных в приложении.
/// Этот протокол определяет основные функции, которые должен реализовать сервис для управления моделями данных,
/// такими как получение и сохранение настроек приложения, кошельков и других связанных с ними данных.
public protocol IModelHandlerService {
  /// Получает модель `oChatModel` асинхронно.
  /// - Parameter completion: Блок завершения, который вызывается с `oChatModel` после завершения операции.
  func getoChatModel(completion: @escaping (oChatModel) -> Void)
  
  /// Удалить все данные из основной модели
  @discardableResult
  func deleteAllData() -> Bool
  
  /// Сохраняет модель `oChatModel` асинхронно.
  /// - Parameters:
  ///   - model: Модель `oChatModel`, которая будет сохранена.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции сохранения.
  func saveoChatModel(_ model: oChatModel, completion: (() -> Void)?)
  
  /// Получает модель настроек приложения `AppSettingsModel` асинхронно.
  /// - Parameter completion: Блок завершения, который вызывается с `AppSettingsModel` после завершения операции.
  func getAppSettingsModel(completion: @escaping (AppSettingsModel) -> Void)
  
  /// Сохраняет модель настроек приложения `AppSettingsModel` асинхронно.
  /// - Parameters:
  ///   - model: Модель `AppSettingsModel`, которая будет сохранена.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции сохранения.
  func saveAppSettingsModel(_ model: AppSettingsModel, completion: (() -> Void)?)
  
  /// Получает массив моделей кошельков `WalletModel` асинхронно.
  /// - Parameter completion: Блок завершения, который вызывается с массивом `WalletModel` после завершения операции.
  func getWalletModels(completion: @escaping ([WalletModel]) -> Void)
  
  /// Сохраняет массив моделей кошельков `WalletModel` асинхронно.
  /// - Parameters:
  ///   - model: Модель `WalletModel`, которая будутет сохранена.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции сохранения.
  func saveWalletModel(_ model: WalletModel, completion: (() -> Void)?)
  
  /// Сохраняет массив моделей кошельков `WalletModel` асинхронно.
  /// - Parameters:
  ///   - models: Массив моделей `WalletModel`, которые будут сохранены.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции сохранения. Может быть `nil`.
  func saveWalletModels(_ models: [WalletModel], completion: (() -> Void)?)
}
