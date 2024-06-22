//
//  String+HexStringToBytes.swift
//  ToxCore
//
//  Created by Vitalii Sosin on 15.06.2024.
//

import Foundation

extension String {
  /// Преобразует строку в массив байтов, интерпретируя её как шестнадцатеричное представление.
  func hexStringToBytes() -> [UInt8]? {
    var bytes = [UInt8]()
    var index = startIndex
    
    while index < endIndex {
      let nextIndex = self.index(index, offsetBy: 2, limitedBy: endIndex) ?? endIndex
      let byteString = self[index..<nextIndex]
      
      if let byte = UInt8(byteString, radix: 16) {
        bytes.append(byte)
      } else {
        return nil
      }
      
      index = nextIndex
    }
    
    return bytes
  }
}
