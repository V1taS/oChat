//
//  Collection+Optional.swift
//
//
//  Created by Vitalii Sosin on 27.01.2024.
//

import Foundation

// Расширение для опциональных коллекций
extension Optional where Wrapped: Collection {
  /// Проверяет, что опциональная коллекция не равна nil и не пуста.
  public var isNotNilAndNotEmpty: Bool {
    guard let collection = self else {
      return false
    }
    return !collection.isEmpty
  }
}

// Расширение специально для Optional<String>
extension Optional where Wrapped == String {
  /// Проверяет, что опциональная строка не равна nil и не пуста.
  public var isNotNilAndNotEmpty: Bool {
    guard let string = self else {
      return false
    }
    return !string.isEmpty
  }
}
