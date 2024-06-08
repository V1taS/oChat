//
//  StegoDefaults.swift
//
//
//  Created by Vitalii Sosin on 19.05.2024.
//

import Foundation

/// Константы по умолчанию для стеганографии
enum StegoDefaults {
  /// Начальный сдвиг битов
  static let INITIAL_SHIFT = 7
  /// Количество байт на пиксель
  static let BYTES_PER_PIXEL = 4
  /// Количество битов на компонент
  static let BITS_PER_COMPONENT = 8
  /// Количество байт для хранения длины сообщения
  static let BYTES_OF_LENGTH = 4
  
  /// Префикс для закодированных данных
  static let DATA_PREFIX = "<m>"
  /// Суффикс для закодированных данных
  static let DATA_SUFFIX = "</m>"
  
  /// Вычисляет размер информации о длине сообщения
  /// - Returns: Размер информации о длине сообщения в битах
  static func sizeOfInfoLength() -> Int {
    return BYTES_OF_LENGTH * BITS_PER_COMPONENT
  }
  
  /// Вычисляет минимальное количество пикселей для закодирования сообщения
  /// - Returns: Минимальное количество пикселей для закодирования сообщения
  static func minPixelsToMessage() -> Int {
    return (DATA_PREFIX.count + DATA_SUFFIX.count) * BITS_PER_COMPONENT
  }
  
  /// Вычисляет минимальное количество пикселей для стеганографического изображения
  /// - Returns: Минимальное количество пикселей
  static func minPixels() -> Int {
    return sizeOfInfoLength() + minPixelsToMessage()
  }
}
