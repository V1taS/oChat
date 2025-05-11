//
//  CallEvent.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 7.05.2025.
//

import Foundation
import CTox
import CSodium

// MARK: - Публичные события

/// События, которые можно получить из `callEvents`‑потока.
public enum CallEvent: Sendable {
  /// Входящий звонок или изменение состояния текущего.
  /// - Parameters:
  ///   - friendID: ID друга.
  ///   - audioEnabled: `true`, если аудиопоток активен.
  ///   - videoEnabled: `true`, если видеопоток активен.
  case call(friendID: UInt32, audioEnabled: Bool, videoEnabled: Bool)

  /// Получен аудио‑фрейм (формат PCM‑16 LE).
  /// - Parameters:
  ///   - friendID: ID друга‑источника.
  ///   - sampleCount: Количество сэмплов в кадре.
  ///   - channels: Число каналов (1 – моно, 2 – стерео и т.д.).
  ///   - sampleRate: Частота дискретизации в Гц.
  ///   - data: Сырые аудиоданные.
  case audioFrame(friendID: UInt32,
                  sampleCount: UInt32,
                  channels: UInt8,
                  sampleRate: UInt32,
                  data: Data)

  /// Получен видео‑фрейм (YUV 420 planar).
  /// - Parameters:
  ///   - friendID: ID друга‑источника.
  ///   - width/height: Размер кадра.
  ///   - y/u/v: Плоскости яркости и цветности.
  ///   - yStride/uStride/vStride: Шаг (байт на строку) для каждой плоскости.
  case videoFrame(friendID: UInt32,
                  width: UInt16, height: UInt16,
                  y: Data, u: Data, v: Data,
                  yStride: Int32, uStride: Int32, vStride: Int32)
}
