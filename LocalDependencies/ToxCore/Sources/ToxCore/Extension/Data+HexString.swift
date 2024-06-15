//
//  Data+HexString.swift
//
//
//  Created by Vitalii Sosin on 09.06.2024.
//

import Foundation

/// Расширение для создания `Data` из шестнадцатеричной строки.
extension Data {
  /// Инициализация данных из шестнадцатеричной строки.
  init?(hexString: String) {
    let len = hexString.count / 2
    var data = Data(capacity: len)
    var index = hexString.startIndex
    for _ in 0..<len {
      let nextIndex = hexString.index(index, offsetBy: 2)
      if let b = UInt8(hexString[index..<nextIndex], radix: 16) {
        data.append(b)
      } else {
        return nil
      }
      index = nextIndex
    }
    self = data
  }
  
  /// Преобразование данных в шестнадцатеричную строку.
  func toHexString() -> String? {
    return self.map { String(format: "%02x", $0) }.joined()
  }
  
  /// Инициализатор для создания `Data` из массива `CChar`.
  /// - Parameter cString: Массив `CChar`, представляющий C строку.
  init(cString: [CChar]) {
    self.init(cString.map { UInt8(bitPattern: $0) })
  }
}
