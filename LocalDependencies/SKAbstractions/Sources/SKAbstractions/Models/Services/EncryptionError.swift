//
//  EncryptionError.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import Foundation

/// Перечисление `EncryptionError`, описывающее возможные ошибки шифрования.
public enum EncryptionError: Error {
  /// Ошибка, возникающая, если ключ шифрования не найден.
  case keyNotFound
  
  /// Ошибка шифрования с передачей конкретной причины в виде строки.
  case encryptionFailed
  
  /// Ошибка расшифровки с передачей конкретной причины в виде строки.
  case decryptionFailed
  
  /// Что то пошло не так
  case somethingWentWrong(String?)
}
