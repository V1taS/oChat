//
//  FileKind.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 07.05.2025.
//

import Foundation
import CTox
import CSodium

// MARK: – Тип передаваемого файла (Swift‑friendly)

/// Назначение передаваемого файла.
///
/// `toxcore` оперирует просто `uint32_t`. Этот enum позволяет
/// описывать предустановленные типы и легко получать/передавать
/// их как `UInt32`.
public enum FileKind: UInt32, Sendable {
  /// Произвольные данные (значение `0`).
  case data = 0   // TOX_FILE_KIND_DATA
  /// Аватар (значение `1`).
  case avatar = 1   // TOX_FILE_KIND_AVATAR

  // MARK: – Маппинг на/из C‑значения

  /// Создаём из `uint32_t`, приходящего из toxcore.
  /// Неизвестные значения согласно рекомендациям трактуем как `.data`.
  public init(cValue: UInt32) {
    switch cValue {
    case Self.avatar.rawValue: self = .avatar
    default: self = .data
    }
  }

  /// Значение, которое нужно передать в C‑API (`uint32_t`).
  public var cValue: UInt32 { rawValue }
}
