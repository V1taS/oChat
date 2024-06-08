//
//  IMessengerModelHandlerService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import Foundation

/// Протокол `IMessengerModelHandlerService` предназначен для обработки и управления моделями данных в приложении.
/// Этот протокол определяет основные функции, которые должен реализовать сервис для управления моделями данных,
/// такими как получение и сохранение настроек приложения, контактов и других связанных с ними данных.
public protocol IMessengerModelHandlerService {
  /// Получает модель `MessengerModel` асинхронно.
  /// - Parameter completion: Блок завершения, который вызывается с `MessengerModel` после завершения операции.
  func getMessengerModel(completion: @escaping (MessengerModel) -> Void)
  
  /// Удалить все данные из основной модели
  @discardableResult
  func deleteAllData() -> Bool
  
  /// Сохраняет модель `MessengerModel` асинхронно.
  /// - Parameters:
  ///   - model: Модель `MessengerModel`, которая будет сохранена.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции сохранения.
  func saveMessengerModel(_ model: MessengerModel, completion: (() -> Void)?)
  
  /// Получает модель настроек приложения `AppSettingsModel` асинхронно.
  /// - Parameter completion: Блок завершения, который вызывается с `AppSettingsModel` после завершения операции.
  func getAppSettingsModel(completion: @escaping (AppSettingsModel) -> Void)
  
  /// Сохраняет модель настроек приложения `AppSettingsModel` асинхронно.
  /// - Parameters:
  ///   - model: Модель `AppSettingsModel`, которая будет сохранена.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции сохранения.
  func saveAppSettingsModel(_ model: AppSettingsModel, completion: (() -> Void)?)
  
  /// Получает массив моделей контактов `ContactModel` асинхронно.
  /// - Parameter completion: Блок завершения, который вызывается с массивом `ContactModel` после завершения операции.
  func getContactModels(completion: @escaping ([ContactModel]) -> Void)
  
  /// Сохраняет `ContactModel` асинхронно.
  /// - Parameters:
  ///   - model: Модель `ContactModel`, которая будутет сохранена.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции сохранения.
  func saveContactModel(_ model: ContactModel, completion: (() -> Void)?)
  
  /// Сохраняет массив моделей контактов `ContactModel` асинхронно.
  /// - Parameters:
  ///   - models: Массив моделей `ContactModel`, которые будут сохранены.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции сохранения. Может быть `nil`.
  func saveContactModels(_ models: [ContactModel], completion: (() -> Void)?)
  
  /// Удаляет модель контакта `ContactModel` асинхронно.
  /// - Parameters:
  ///   - contactModel: Модель `ContactModel`, которая будет удалена.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции удаления. Может быть `nil`.
  func removeContactModels(_ contactModel: ContactModel, completion: (() -> Void)?)
}
