//
//  StegoErrorDomainCode.swift
//
//
//  Created by Vitalii Sosin on 19.05.2024.
//

import Foundation

/// Перечисление кодов ошибок для стеганографии
public enum StegoError: Error {
  /// Ошибка не определена
  case notDefined
  /// Данные слишком велики для сокрытия
  case dataTooBig
  /// Изображение слишком мало для сокрытия данных
  case imageTooSmall
  /// Нет данных в изображении
  case noDataInImage
}
