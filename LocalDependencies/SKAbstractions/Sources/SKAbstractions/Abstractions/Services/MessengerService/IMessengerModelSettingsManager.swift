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
  
  /// Устанавливает, является ли контакт онлайн
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - status: Значение, указывающее, является ли контакт онлайн 
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func setStatus(
    _ model: ContactModel,
    _ status: ContactModel.Status,
    completion: (() -> Void)?
  )
  
  /// Устанавливает, защиту на конкретный диалог
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - value: Значение, указывающее,  защиту на конкретный диалог (`true`) или нет (`false`).
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func setIsPasswordDialogProtected(
    _ model: ContactModel,
    _ value: Bool,
    completion: (() -> Void)?
  )
  
  /// Устанавливает имя контакта.
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - name: Новое имя для контакта.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func setNameContact(
    _ model: ContactModel,
    _ name: String,
    completion: ((_ model: ContactModel?) -> Void)?
  )
  
  /// Устанавливает адрес контакта.
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - address: Новый адрес для контакта.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func setOnionAddress(
    _ model: ContactModel,
    _ address: String,
    completion: ((_ model: ContactModel?) -> Void)?
  )
  
  /// Устанавливает локальный адрес контакта.
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - meshAddress: Новый локальный адрес для контакта.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func setMeshAddress(
    _ model: ContactModel,
    _ meshAddress: String,
    completion: ((_ model: ContactModel?) -> Void)?
  )
  
  /// Добавляет сообщение для контакта
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - messengeModel: Сообщение для контакта
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func addMessenge(
    _ model: ContactModel,
    _ messengeModel: MessengeModel,
    completion: ((_ model: ContactModel?) -> Void)?
  )
  
  /// Устанавливает публичный ключ для шифрования сообщений.
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`.
  ///   - publicKey: Новый публичный ключ для шифрования сообщений.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func setEncryptionPublicKey(
    _ model: ContactModel,
    _ publicKey: String,
    completion: ((_ model: ContactModel?) -> Void)?
  )
  
  /// Удаляет контакт.
  /// - Parameters:
  ///   - model: Модель контакта `ContactModel`, которую нужно удалить.
  ///   - completion: Опциональный блок завершения, который вызывается после завершения операции. Может быть `nil`.
  func deleteContact(
    _ model: ContactModel,
    completion: (() -> Void)?
  )
}