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
  /// Имя миниатюры видео
  public let thumbnailName: String
  /// Имя полного видео
  public let fullName: String
  
  /// Инициализатор модели видео
  /// - Parameters:
  ///   - id: Уникальный идентификатор видео
  ///   - thumbnail: URL миниатюры видео
  ///   - full: URL полного видео
  public init(id: String, thumbnailName: String, fullName: String) {
    self.id = id
    self.thumbnailName = thumbnailName
    self.fullName = fullName
  }
}

// MARK: - URLs

public extension MessengeVideoModel {
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

extension MessengeVideoModel: IdentifiableAndCodable {}
