//
//  IContactManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import Foundation

/// Протокол для управления контактами.
public protocol IContactManager {
  /// Возвращает список моделей контактов.
  /// - Returns: Список моделей контактов.
  func getContactModels() async -> [ContactModel]
  
  /// Сохраняет модель контакта.
  /// - Parameter model: Модель контакта.
  func saveContactModel(_ model: ContactModel) async
  
  /// Удаляет модель контакта.
  /// - Parameter contactModel: Модель контакта.
  /// - Returns: `true`, если удаление успешно, иначе `false`.
  func removeContactModel(_ contactModel: ContactModel) async -> Bool
  
  /// Возвращает модель контакта по адресу Tox.
  /// - Parameter toxAddress: Адрес Tox.
  /// - Returns: Модель контакта или nil, если контакт не найден.
  func getContactModelFrom(toxAddress: String) async -> ContactModel?
  
  /// Возвращает модель контакта по публичному ключу Tox.
  /// - Parameter toxPublicKey: Публичный ключ Tox.
  /// - Returns: Модель контакта или nil, если контакт не найден.
  func getContactModelFrom(toxPublicKey: String) async -> ContactModel?
  
  /// Устанавливает статус для контакта.
  /// - Parameters:
  ///   - model: Модель контакта.
  ///   - status: Новый статус контакта.
  func setStatus(_ model: ContactModel, _ status: ContactModel.Status) async
  
  /// Устанавливает всем контактам статус "оффлайн".
  func setAllContactsOffline() async
  
  /// Устанавливает всем контактам статус "не печатает".
  func setAllContactsNotTyping() async
  
  /// Очищает все временные идентификаторы сообщений.
  func clearAllMessengeTempID() async
}
