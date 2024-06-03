//
//  SystemServiceError.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import Foundation

// Ошибки, связанные с системными службами
public enum SystemServiceError: Error {
  /// Не удается создать URL для системных настройки
  case unableToCreateURL
  /// Не удается открыть экран с системными настройками
  case failedToOpenURL
  /// Ошибка при копировании текста в буфер обмена
  case failedToCopyToClipboard
  /// Пароль не установлен на устройстве
  case passcodeNotSet
}
