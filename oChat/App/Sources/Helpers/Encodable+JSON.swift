//
//  Encodable+JSON.swift
//  oChat
//
//  Created by Vitalii Sosin on 22.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

enum JSONCodingError: Error { case encodingFailed }

public extension Encodable {
  /// Преобразует объект в JSON‑строку.
  /// - Returns: Строка или `nil`, если кодирование не удалось.
  func toJSONString() -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    do {
      let data = try encoder.encode(self)
      return String(data: data, encoding: .utf8)
    } catch {
      print("[Encodable+JSON] Ошибка кодирования: \(error)")
      return nil
    }
  }
}
