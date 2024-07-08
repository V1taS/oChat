//
//  MessengeRecordingModel.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 02.07.2024.
//

import Foundation

public struct MessengeRecordingModel {
  /// Продолжительность записи в секундах
  public var duration: Double
  /// Массив выборок формы волны записи
  public var waveformSamples: [CGFloat]
  /// Полное название файла
  public var name: String
  
  /// Инициализатор модели записи
  /// - Parameters:
  ///   - duration: Продолжительность записи в секундах
  ///   - waveformSamples: Массив выборок формы волны записи
  ///   - name: Полное название файла
  public init(duration: Double, waveformSamples: [CGFloat], name: String) {
    self.duration = duration
    self.waveformSamples = waveformSamples
    self.name = name
  }
}

// MARK: - URLs

public extension MessengeRecordingModel {
  var url: URL? {
    let directoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
    return directoryURL?.appendingPathComponent(name)
  }
}

// MARK: - IdentifiableAndCodable

extension MessengeRecordingModel: IdentifiableAndCodable {}
