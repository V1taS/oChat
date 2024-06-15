//
//  ToxNode.swift
//  ToxCore
//
//  Created by Vitalii Sosin on 15.06.2024.
//

import Foundation

/// Модель узла Tox, представляющая данные о сети и узлах.
struct ToxNode: Codable {
  /// IPv4-адрес узла.
  let ipv4: String
  
  /// IPv6-адрес узла, если он доступен.
  let ipv6: String?
  
  /// Порт, используемый для подключения к узлу.
  let port: UInt16
  
  /// Публичный ключ узла для установления безопасного соединения.
  let publicKey: String
  
  /// Имя или псевдоним администратора узла, если он доступен.
  let maintainer: String?
  
  /// Текущий статус узла (например, "ONLINE" или "OFFLINE"), если он доступен.
  let status: String?
  
  // MARK: - Init
  
  /// Инициализирует новый экземпляр `ToxNode` из декодера.
  /// - Parameter decoder: Декодер, используемый для извлечения данных из JSON.
  /// - Throws: Ошибка декодирования, если не удаётся преобразовать данные.
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.ipv4 = try container.decode(String.self, forKey: .ipv4)
    self.ipv6 = try container.decodeIfPresent(String.self, forKey: .ipv6)
    
    // Преобразуем строку в UInt16 для порта
    let portString = try container.decode(String.self, forKey: .port)
    guard let port = UInt16(portString) else {
      throw DecodingError.dataCorruptedError(forKey: .port, in: container, debugDescription: "Port could not be converted to UInt16")
    }
    self.port = port
    
    self.publicKey = try container.decode(String.self, forKey: .publicKey)
    self.maintainer = try container.decodeIfPresent(String.self, forKey: .maintainer)
    self.status = try container.decodeIfPresent(String.self, forKey: .status)
  }
}

// MARK: - CodingKeys

extension ToxNode {
  /// Ключи для декодирования данных из JSON.
  enum CodingKeys: String, CodingKey {
    case ipv4 = "IPv4"
    case ipv6 = "IPv6"
    case port = "Port"
    case publicKey = "Public Key"
    case maintainer = "Maintainer"
    case status = "Status"
  }
}

// MARK: - ParseToxNodes

extension ToxNode {
  /// Парсит JSON-строку в массив моделей `ToxNode`.
  /// - Parameter jsonString: JSON-строка, содержащая данные узлов.
  /// - Returns: Массив моделей `ToxNode` или пустой массив в случае ошибки.
  static func parseToxNodes(from jsonString: String) -> [ToxNode] {
    // Очистка строки от ненужных символов
    let cleanJsonString = jsonString
      .replacingOccurrences(of: "\\n", with: "")
      .replacingOccurrences(of: "\\", with: "")
      .replacingOccurrences(of: "\n", with: "")
      .replacingOccurrences(of: "\"", with: "\"")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard let jsonData = cleanJsonString.data(using: .utf8) else {
      print("Ошибка преобразования строки в Data")
      return []
    }
    
    do {
      let decoder = JSONDecoder()
      let toxNodes = try decoder.decode([ToxNode].self, from: jsonData)
      return toxNodes
    } catch {
      print("Ошибка декодирования JSON: \(error)")
      return []
    }
  }
}
