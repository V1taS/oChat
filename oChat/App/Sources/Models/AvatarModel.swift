//
//  AvatarModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

struct AvatarModel: Identifiable, Equatable, Codable {
  let id: UUID

  /// Публичное API: 'color' по-прежнему имеет тип `Color`
  var color: Color {
    get { codableColor.color }
    set { codableColor = CodableColor(newValue) }
  }

  /// Выбранная иконка (SF Symbol или эмодзи)
  var icon: IconType = .customEmoji("?")

  // Хранится и сериализуется этот тип
  private var codableColor: CodableColor

  init(id: UUID = UUID(), icon: AvatarModel.IconType = .customEmoji("?"), color: Color = .blue) {
    self.id = id
    self.icon = icon
    self.codableColor = CodableColor(color)
  }
}

extension AvatarModel {
  // MARK: - IconType

  /// Типы иконок, которые может выбрать пользователь
  /// - `.systemSymbol(String)`: системная иконка SF Symbols (например "star.fill")
  /// - `.customEmoji(String)`: пользовательская эмодзи (например "🍎")
  enum IconType: Equatable, Hashable {
    case systemSymbol(String)
    case customEmoji(String)
  }
}

// MARK: - IconType + Codable

extension AvatarModel.IconType: Codable {
  private enum CodingKeys: String, CodingKey {
    case type
    case value
  }

  enum IconTypeError: Error {
    case unknownType(String)
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let typeString = try container.decode(String.self, forKey: .type)
    let value = try container.decode(String.self, forKey: .value)

    switch typeString {
    case "systemSymbol":
      self = .systemSymbol(value)
    case "customEmoji":
      self = .customEmoji(value)
    default:
      throw IconTypeError.unknownType(typeString)
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .systemSymbol(let symbolName):
      try container.encode("systemSymbol", forKey: .type)
      try container.encode(symbolName, forKey: .value)
    case .customEmoji(let emoji):
      try container.encode("customEmoji", forKey: .type)
      try container.encode(emoji, forKey: .value)
    }
  }
}

// MARK: - CodableColor

/// Специальная структура для кодирования/декодирования SwiftUI.Color
struct CodableColor: Codable, Equatable {
  private let red: Double
  private let green: Double
  private let blue: Double
  private let alpha: Double

  /// Инициализатор из SwiftUI.Color
  init(_ color: Color) {
#if canImport(UIKit)
    let uiColor = UIColor(color)
    var (r, g, b, a) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
    uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
    self.red   = Double(r)
    self.green = Double(g)
    self.blue  = Double(b)
    self.alpha = Double(a)
#elseif canImport(AppKit)
    let nsColor = NSColor(color)
    var (r, g, b, a) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
    nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
    self.red   = Double(r)
    self.green = Double(g)
    self.blue  = Double(b)
    self.alpha = Double(a)
#else
    // Фолбэк, если ни UIKit, ни AppKit нет
    self.red   = 0
    self.green = 0
    self.blue  = 0
    self.alpha = 1
#endif
  }

  /// Преобразовать обратно в SwiftUI.Color
  var color: Color {
    // Можно использовать .sRGB или любой другой нужный цветовое пространство.
    Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
  }
}
