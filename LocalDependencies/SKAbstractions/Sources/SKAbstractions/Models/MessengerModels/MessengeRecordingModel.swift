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
  /// URL записи (опционально)
  public var url: URL?
  
  /// Инициализатор модели записи
  /// - Parameters:
  ///   - duration: Продолжительность записи в секундах
  ///   - waveformSamples: Массив выборок формы волны записи
  ///   - url: URL записи (опционально)
  public init(duration: Double, waveformSamples: [CGFloat], url: URL? = nil) {
    self.duration = duration
    self.waveformSamples = waveformSamples
    self.url = url
  }
}

// MARK: - IdentifiableAndCodable

extension MessengeRecordingModel: IdentifiableAndCodable {}
