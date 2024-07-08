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
  /// Имя миниатюры изображения
  public let thumbnailName: String
  /// Имя полного изображения
  public let fullName: String
  
  /// Инициализатор модели изображения
  /// - Parameters:
  ///   - id: Уникальный идентификатор изображения
  ///   - thumbnail: URL миниатюры изображения
  ///   - full: URL полного изображения
  public init(id: String, thumbnailName: String, fullName: String) {
    self.id = id
    self.thumbnailName = thumbnailName
    self.fullName = fullName
  }
}

// MARK: - URLs

public extension MessengeImageModel {
  var thumbnail: URL? {
    let directoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
    return directoryURL?.appendingPathComponent(thumbnailName)
  }
  
  var full: URL? {
    let directoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
    return directoryURL?.appendingPathComponent(fullName)
  }
}

// MARK: - IdentifiableAndCodable

extension MessengeImageModel: IdentifiableAndCodable {}
