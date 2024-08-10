//
//  IMessengeDataManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 10.08.2024.
//

import Foundation

/// Протокол `IMessengeDataManager` предназначен для управления сообщениями
public protocol IMessengeDataManager {
  
  /// Получить словарь моделей сообщений
  /// - Returns: Асинхронная операция, возвращающая словарь моделей сообщений `MessengeModels`
  func getDictionaryMessengeModels() async -> MessengeModels
  
  /// Получить список моделей сообщений для определенного контакта
  /// - Parameter contactModel: Модель контакта `ContactModel`
  /// - Returns: Асинхронная операция, возвращающая список моделей сообщений `[MessengeModel]` для данного контакта
  func getListMessengeModels(_ contactModel: ContactModel) async -> [MessengeModel]
  
  /// Сохранить словарь моделей сообщений
  /// - Parameter models: Словарь моделей сообщений `MessengeModels`, который необходимо сохранить
  func saveMessengeModels(_ models: MessengeModels) async
  
  /// Удалить сообщение
  /// - Parameters:
  ///   - contactModel: Модель контакта `ContactModel`, связанная с сообщением, которое нужно удалить
  ///   - id: Идентификатор сообщения, которое нужно удалить
  func removeMessenge(_ contactModel: ContactModel, _ id: String) async
  
  /// Удалить все сообщения для контакта.
  /// - Parameters:
  ///   - contactModel: Модель контакта `ContactModel`, для которого нужно удалить все сообщения.
  func removeMessenges(_ contactModel: ContactModel) async
  
  /// Очистить все сообщения
  func clearAllMessenge() async
  
  /// Добавить сообщение для контакта
  /// - Parameters:
  ///   - contactID: ID контакта
  ///   - messengeModel: Модель сообщения `MessengeModel`
  func addMessenge(_ contactID: String, _ messengeModel: MessengeModel) async
  
  /// Получить список сообщений для контакта.
  /// - Parameters:
  ///   - contactID: Уникальный идентификатор контакта, для которого необходимо получить сообщения.
  /// - Returns: Массив объектов `MessengeModel`, представляющих сообщения для указанного контакта.
  func getMessengeModelsFor(_ contactID: String) async -> [MessengeModel]
  
  /// Этот метод обновляет существующее сообщение для заданного контакта.
  /// - Parameters:
  ///   - contactModel: Модель контакта `ContactModel`
  ///   - messengeModel: Обновленная модель сообщения `MessengeModel`
  func updateMessenge(_ contactModel: ContactModel, _ messengeModel: MessengeModel) async
  
  /// Очистить все временные ID сообщений
  func clearAllMessengeTempID() async
}
