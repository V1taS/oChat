//
//  MessengeImageModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 02.07.2024.
//

import Foundation

/// Модель изображения сообщения
public struct MessengeImageModel {
  /// Уникальный идентификатор изображения
  public let id: String
  /// URL миниатюры изображения
  public let thumbnail: URL
  /// URL полного изображения
  public let full: URL
  
  /// Инициализатор модели изображения
  /// - Parameters:
  ///   - id: Уникальный идентификатор изображения
  ///   - thumbnail: URL миниатюры изображения
  ///   - full: URL полного изображения
  public init(id: String, thumbnail: URL, full: URL) {
    self.id = id
    self.thumbnail = thumbnail
    self.full = full
  }
}

// MARK: - IdentifiableAndCodable

extension MessengeImageModel: IdentifiableAndCodable {}
