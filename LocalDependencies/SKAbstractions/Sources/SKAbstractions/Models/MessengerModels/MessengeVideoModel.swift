//
//  MessengeVideoModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 02.07.2024.
//

import Foundation

/// Модель видео сообщения
public struct MessengeVideoModel {
  /// Уникальный идентификатор видео
  public let id: String
  /// URL миниатюры видео
  public let thumbnail: URL
  /// URL полного видео
  public let full: URL
  
  /// Инициализатор модели видео
  /// - Parameters:
  ///   - id: Уникальный идентификатор видео
  ///   - thumbnail: URL миниатюры видео
  ///   - full: URL полного видео
  public init(id: String, thumbnail: URL, full: URL) {
    self.id = id
    self.thumbnail = thumbnail
    self.full = full
  }
}

// MARK: - IdentifiableAndCodable

extension MessengeVideoModel: IdentifiableAndCodable {}
