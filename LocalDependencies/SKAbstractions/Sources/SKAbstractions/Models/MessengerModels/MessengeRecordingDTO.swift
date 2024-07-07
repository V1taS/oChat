//
//  MessengeRecordingDTO.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 08.07.2024.
//

import Foundation

public struct MessengeRecordingDTO {
  /// Продолжительность записи в секундах
  public var duration: Double
  /// Массив выборок формы волны записи
  public var waveformSamples: [CGFloat]
  /// Запись звука
  public var data: Data
  
  /// Инициализатор модели записи
  /// - Parameters:
  ///   - duration: Продолжительность записи в секундах
  ///   - waveformSamples: Массив выборок формы волны записи
  ///   - data: Запись звука
  public init(duration: Double, waveformSamples: [CGFloat], data: Data) {
    self.duration = duration
    self.waveformSamples = waveformSamples
    self.data = data
  }
}

// MARK: - IdentifiableAndCodable

extension MessengeRecordingDTO: IdentifiableAndCodable {}
