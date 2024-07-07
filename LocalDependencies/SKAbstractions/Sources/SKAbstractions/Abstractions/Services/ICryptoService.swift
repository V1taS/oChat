//
//  ICryptoService.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 10.05.2024.
//

import Foundation

/// Протокол для сервиса шифрования с использованием ECIES (Elliptic Curve Integrated Encryption Scheme).
/// Этот метод шифрования применяет асимметричные ключи:
/// - Приватный ключ, который хранится в тайне и используется для расшифровки данных.
/// - Публичный ключ, который можно безопасно распространять и используется для шифрования данных.
/// Чтобы зашифровать данные, используется публичный ключ получателя.
/// Только приватный ключ получателя может расшифровать зашифрованные данные.
public protocol ICryptoService {
  /// Получает публичный ключ из приватного.
  /// - Parameter privateKey: Приватный ключ.
  /// - Returns: Публичный ключ в виде строки.
  /// - Throws: Ошибка генерации публичного ключа.
  func publicKey(from privateKey: String) -> String?
  
  /// Шифрует данные, используя публичный ключ.
  /// - Parameters:
  ///   - data: Данные для шифрования.
  ///   - publicKey: Публичный ключ.
  /// - Returns: Зашифрованные данные в виде строки.
  /// - Throws: Ошибка шифрования данных.
  func encrypt(_ data: String?, publicKey: String) -> String?
  
  /// Расшифровывает данные, используя приватный ключ.
  /// - Parameters:
  ///   - encryptedData: Зашифрованные данные.
  ///   - privateKey: Приватный ключ.
  /// - Returns: Расшифрованные данные.
  /// - Throws: Ошибка расшифровки данных.
  func decrypt(_ encryptedData: String?, privateKey: String) -> String?
  
  /// Возвращает хеш SHA-512 из строки.
  /// - Parameter input: Строка, из которой необходимо получить хеш.
  /// - Returns: Хеш SHA-512 в виде шестнадцатеричной строки.
  func sha512(from input: String) -> String
  
  /// Возвращает хеш SHA-512 из объекта Data.
  /// - Parameter inputData: Данные, из которых необходимо получить хеш.
  /// - Returns: Хеш SHA-512 в виде шестнадцатеричной строки.
  func sha512(from inputData: Data) -> String
  
  /// Возвращает хеш SHA-256 из строки.
  /// - Parameter input: Строка, из которой необходимо получить хеш.
  /// - Returns: Хеш SHA-256 в виде шестнадцатеричной строки.
  func sha256(from input: String) -> String
  
  /// Возвращает хеш SHA-256 из объекта Data.
  /// - Parameter inputData: Данные, из которых необходимо получить хеш.
  /// - Returns: Хеш SHA-256 в виде шестнадцатеричной строки.
  func sha256(from inputData: Data) -> String
  
  /// Расшифровывает данные, используя приватный ключ.
  /// - Parameters:
  ///   - encryptedData: Зашифрованные данные.
  /// - privateKey: Приватный ключ.
  /// - Returns: Расшифрованные данные в виде объекта Data.
  /// - Throws: Ошибка расшифровки данных.
  func decrypt(_ data: Data?, privateKey: String) -> Data?
  
  /// Шифрует данные, используя публичный ключ.
  /// - Parameters:
  ///   - data: Данные для шифрования.
  ///   - publicKey: Публичный ключ.
  /// - Returns: Зашифрованные данные в виде объекта Data.
  /// - Throws: Ошибка шифрования данных.
  func encrypt(_ data: Data?, publicKey: String) -> Data?
}
