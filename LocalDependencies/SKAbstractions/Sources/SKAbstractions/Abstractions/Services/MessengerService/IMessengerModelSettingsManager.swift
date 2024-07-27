//
//  IMessengerModelSettingsManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import SwiftUI

// MARK: - IMessengerModelSettingsManager

/// Протокол для управления настройками модели контакта.
public protocol IMessengerModelSettingsManager {
  /// Устанавливает состояние Tox в виде строки.
  /// - Parameter toxStateAsString: Строка, представляющая состояние Tox. Если значение `nil`, состояние сбрасывается.
  func setToxStateAsString(_ toxStateAsString: String?) async
  
  /// Устанавливает, является ли контакт онлайн.
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - status: Значение, указывающее, является ли контакт онлайн.
  func setStatus(_ model: ContactModel, _ status: ContactModel.Status) async
  
  /// Устанавливает имя контакта.
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - name: Новое имя для контакта.
  func setNameContact(_ model: ContactModel, _ name: String) async -> ContactModel?
  
  /// Устанавливает адрес контакта.
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - address: Новый адрес для контакта.
  func setToxAddress(_ model: ContactModel, _ address: String) async -> ContactModel?
  
  /// Очищает временные ИД у всех сообщений.
  func clearAllMessengeTempID() async
  
  /// Устанавливает локальный адрес контакта.
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - meshAddress: Новый локальный адрес для контакта.
  func setMeshAddress(_ model: ContactModel, _ meshAddress: String) async -> ContactModel?
  
  /// Добавляет сообщение для контакта.
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - messengeModel: Сообщение для контакта.
  func addMessenge(_ model: ContactModel, _ messengeModel: MessengeModel) async -> ContactModel?
  
  /// Устанавливает публичный ключ для шифрования сообщений.
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - publicKey: Новый публичный ключ для шифрования сообщений.
  func setEncryptionPublicKey(_ model: ContactModel, _ publicKey: String) async -> ContactModel?
  
  /// Сохраняет токен для пуш сообщений.
  /// - Parameter token: Токен для пуш сообщений.
  func saveMyPushNotificationToken(_ token: String) async
  
  /// Удаляет контакт.
  /// - Parameter model: Модель контакта `ContactModel`, которую нужно удалить.
  func deleteContact(_ model: ContactModel) async
  
  /// Переводит всех контактов в состояние оффлайн.
  func setAllContactsIsOffline() async
  
  /// Переводит всех контактов в состояние "Не Печатают".
  func setAllContactsNoTyping() async
}
