//
//  ICryptoManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import Foundation

/// Протокол для управления криптографией.
public protocol ICryptoManager {
  /// Расшифровывает текст.
  /// - Parameter encryptedText: Зашифрованный текст.
  /// - Returns: Расшифрованный текст или nil в случае ошибки.
  func decrypt(_ encryptedText: String?) async -> String?
  
  /// Шифрует текст.
  /// - Parameters:
  ///   - text: Текст для шифрования.
  ///   - publicKey: Публичный ключ.
  /// - Returns: Зашифрованный текст или nil в случае ошибки.
  func encrypt(_ text: String?, publicKey: String) -> String?
  
  /// Расшифровывает данные.
  /// - Parameter encryptedData: Зашифрованные данные.
  /// - Returns: Расшифрованные данные или nil в случае ошибки.
  func decrypt(_ encryptedData: Data?) async -> Data?
  
  /// Шифрует данные.
  /// - Parameters:
  ///   - data: Данные для шифрования.
  ///   - publicKey: Публичный ключ.
  /// - Returns: Зашифрованные данные или nil в случае ошибки.
  func encrypt(_ data: Data?, publicKey: String) -> Data?
  
  /// Возвращает публичный ключ из приватного ключа.
  /// - Parameter privateKey: Приватный ключ.
  /// - Returns: Публичный ключ или nil в случае ошибки.
  func publicKey(from privateKey: String) -> String?
}
