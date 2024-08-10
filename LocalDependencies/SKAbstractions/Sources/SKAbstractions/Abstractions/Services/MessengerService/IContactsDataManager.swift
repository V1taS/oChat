//
//  IContactsDataManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 10.08.2024.
//

import Foundation

/// Протокол `IContactsDataManager` предназначен для управления контактами приложения.
public protocol IContactsDataManager {
  
  /// Получить словарь моделей контактов
  /// - Returns: Асинхронная операция, возвращающая словарь моделей контактов `[String: ContactModel]`
  func getDictionaryContactModels() async -> [String: ContactModel]
  
  /// Получить список моделей контактов
  /// - Returns: Асинхронная операция, возвращающая список моделей контактов `[ContactModel]`
  func getListContactModels() async -> [ContactModel]
  
  /// Сохранить словарь моделей контактов
  /// - Parameter models: Словарь моделей контактов `ContactModels`, который необходимо сохранить
  func saveContactModels(_ models: ContactModels) async
  
  /// Удалить контакт
  /// - Parameter contactModel: Модель контакта, который необходимо удалить
  func removeContact(_ contactModel: ContactModel) async
  
  /// Сохранить контакт
  /// - Parameter contactModel: Модель контакта, который необходимо сохранить
  func saveContact(_ contactModel: ContactModel) async
  
  /// Установить статус новых сообщений для контакта
  /// - Parameters:
  ///   - value: Булево значение, указывающее, есть ли новые сообщения
  ///   - id: Идентификатор контакта
  func setIsNewMessagesAvailable(_ value: Bool, id: String) async
  
  /// Установить публичный ключ шифрования для контакта
  /// - Parameters:
  ///   - contactModel: Модель контакта
  ///   - publicKey: Публичный ключ шифрования
  /// - Returns: Обновленная модель контакта, либо `nil`, если контакт не найден
  func setEncryptionPublicKey(_ contactModel: ContactModel, _ publicKey: String) async -> ContactModel?
  
  /// Установить mesh-адрес для контакта
  /// - Parameters:
  ///   - contactModel: Модель контакта
  ///   - meshAddress: Mesh-адрес
  /// - Returns: Обновленная модель контакта, либо `nil`, если контакт не найден
  func setMeshAddress(_ contactModel: ContactModel, _ meshAddress: String) async -> ContactModel?
  
  /// Установить Tox-адрес для контакта
  /// - Parameters:
  ///   - contactModel: Модель контакта
  ///   - address: Tox-адрес
  /// - Returns: Обновленная модель контакта, либо `nil`, если контакт не найден
  func setToxAddress(_ contactModel: ContactModel, _ address: String) async -> ContactModel?
  
  /// Установить имя для контакта
  /// - Parameters:
  ///   - contactModel: Модель контакта
  ///   - name: Новое имя контакта
  /// - Returns: Обновленная модель контакта, либо `nil`, если контакт не найден
  func setNameContact(_ contactModel: ContactModel, _ name: String) async -> ContactModel?
  
  /// Установить статус "не печатает" для всех контактов
  func setAllContactsNoTyping() async
  
  /// Установить статус "оффлайн" для всех контактов
  func setAllContactsIsOffline() async
  
  /// Установить статус для контакта
  /// - Parameters:
  ///   - contactModel: Модель контакта
  ///   - status: Новый статус контакта
  func setStatus(_ contactModel: ContactModel, _ status: ContactModel.Status) async
}
