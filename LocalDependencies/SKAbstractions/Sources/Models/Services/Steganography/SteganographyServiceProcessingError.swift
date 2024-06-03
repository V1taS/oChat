//
//  SteganographyServiceProcessingError.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import Foundation

/// Ошибки, связанные с обработкой изображений.
public enum SteganographyServiceProcessingError: Error {
  /// Ошибка не определена
  case notDefined
  /// Данные слишком велики для сокрытия
  case dataTooBig
  /// Изображение слишком мало для сокрытия данных
  case imageTooSmall
  /// Нет данных в изображении
  case noDataInImage
}
