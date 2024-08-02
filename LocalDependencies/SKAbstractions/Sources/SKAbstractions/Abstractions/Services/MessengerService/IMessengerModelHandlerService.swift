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
  func getMessengerModel() async -> MessengerModel
  
  /// Удалить все данные из основной модели
  @discardableResult
  func deleteAllData() -> Bool
  
  /// Очистить все переписки у всех пользователей
  func clearAllMessenge() async
  
  /// Получает модель настроек приложения `AppSettingsModel` асинхронно.
  func getAppSettingsModel() async -> AppSettingsModel
  
  /// Сохраняет модель настроек приложения `AppSettingsModel` асинхронно.
  /// - Parameter model: Модель `AppSettingsModel`, которая будет сохранена.
  func saveAppSettingsModel(_ model: AppSettingsModel) async
  
  /// Получает массив моделей контактов `ContactModel` асинхронно.
  func getContactModels() async -> [ContactModel]
  
  /// Сохраняет `ContactModel` асинхронно.
  /// - Parameter model: Модель `ContactModel`, которая будет сохранена.
  func saveContactModel(_ model: ContactModel) async
  
  /// Сохраняет массив моделей контактов `ContactModel` асинхронно.
  /// - Parameter models: Массив моделей `ContactModel`, которые будут сохранены.
  func saveContactModels(_ models: [ContactModel]) async
  
  /// Удаляет модель контакта `ContactModel` асинхронно.
  /// - Parameter contactModel: Модель `ContactModel`, которая будет удалена.
  func removeContactModels(_ contactModel: ContactModel) async
}
