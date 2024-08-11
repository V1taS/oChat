//
//  PremiumModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 11.08.2024.
//

import Foundation

/// Модель данных для премиум-пользователя.
public struct PremiumModel {
  
  // MARK: - Public properties
  
  /// Определяет, является ли пользователь премиум.
  public let isPremium: Bool
  
  /// Имя пользователя.
  public let name: String
  
  /// Дата истечения премиум-статуса в формате строки ("dd.mm.yyyy"). Может быть `nil`.
  public let expirationDate: Date?
  
  /// Идентификатор вендора.
  public let vendorID: String
  
  // MARK: - Init
  
  /// Инициализатор для создания модели `PremiumModel`.
  /// - Parameters:
  ///   - isPremium: Булево значение, указывающее на наличие премиум-статуса.
  ///   - name: Имя пользователя.
  ///   - expirationDate: Дата истечения премиум-статуса. Может быть `nil`.
  ///   - vendorID: Идентификатор вендора.
  public init(isPremium: Bool, name: String, expirationDate: Date?, vendorID: String) {
    self.isPremium = isPremium
    self.name = name
    self.expirationDate = expirationDate
    self.vendorID = vendorID
  }
  
  /// Кастомный инициализатор для декодирования JSON.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.isPremium = try container.decode(Bool.self, forKey: .isPremium)
    self.name = try container.decode(String.self, forKey: .name)
    self.vendorID = try container.decode(String.self, forKey: .vendorID)
    
    // Декодируем дату из строки
    let dateString = try container.decode(String.self, forKey: .expirationDate)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    self.expirationDate = dateFormatter.date(from: dateString)
  }
  
  // MARK: - Public funcs
  
  /// Метод для декодирования JSON в массив объектов `PremiumModel`.
  ///
  /// - Parameter jsonData: Данные JSON, которые нужно декодировать.
  /// - Returns: Массив объектов `PremiumModel` или `nil`, если декодирование не удалось.
  public static func decodeFromJSON(_ jsonData: Data) -> [PremiumModel] {
    let decoder = JSONDecoder()
    do {
      let premiums = try decoder.decode([PremiumModel].self, from: jsonData)
      return premiums
    } catch {
      print("Ошибка декодирования JSON: \(error)")
      return []
    }
  }
}

// MARK: - IdentifiableAndCodable

extension PremiumModel: IdentifiableAndCodable {}
