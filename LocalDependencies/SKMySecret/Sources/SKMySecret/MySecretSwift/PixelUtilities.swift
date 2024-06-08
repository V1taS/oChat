//
//  PixelUtilities.swift
//
//
//  Created by Vitalii Sosin on 19.05.2024.
//

import Foundation

/// Утилиты для работы с пикселями
enum PixelUtilities {
  /// Создает новый пиксель с заданным сдвигом битов
  /// - Parameters:
  ///   - pixel: Исходный пиксель
  ///   - shiftedBits: Сдвинутые биты
  ///   - shift: Сдвиг в битах
  /// - Returns: Новый пиксель с заданным сдвигом битов
  static func newPixel(_ pixel: UInt32, shiftedBits: UInt32, shift: Int) -> UInt32 {
    let bit = (shiftedBits & 1) << UInt32(8 * shift)
    let colorAndNot = pixel & ~(1 << UInt32(8 * shift))
    return colorAndNot | bit
  }
  
  /// Маска для выделения младших 8 бит
  /// - Parameter x: Число, из которого нужно выделить младшие 8 бит
  /// - Returns: Младшие 8 бит числа
  static func mask8(_ x: UInt32) -> UInt32 {
    return x & 0xFF
  }
  
  /// Извлечение цвета из числа с заданным сдвигом
  /// - Parameters:
  ///   - x: Число, из которого извлекается цвет
  ///   - shift: Сдвиг в битах
  /// - Returns: Цвет, извлеченный из числа
  static func color(_ x: UInt32, shift: Int) -> UInt32 {
    return mask8(x >> UInt32(8 * shift))
  }
  
  /// Добавляет биты одного числа к другому с заданным сдвигом
  /// - Parameters:
  ///   - number1: Первое число
  ///   - number2: Второе число
  ///   - shift: Сдвиг в битах
  /// - Returns: Результат добавления битов
  static func addBits(_ number1: UInt32, _ number2: UInt32, shift: Int) -> UInt32 {
    return number1 | (mask8(number2) << UInt32(8 * shift))
  }
  
  /// Преобразует цвет пикселя в значение PixelColor
  /// - Parameter pixel: Цвет пикселя
  /// - Returns: Значение PixelColor
  static func colorToStep(_ pixel: UInt32) -> PixelColor {
    if pixel % 3 == 0 {
      return .blue
    } else if pixel % 2 == 0 {
      return .green
    } else {
      return .red
    }
  }
}
