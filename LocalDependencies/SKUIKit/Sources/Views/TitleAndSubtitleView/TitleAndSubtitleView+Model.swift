//
//  TitleAndSubtitleView+Model.swift
//
//
//  Created by Vitalii Sosin on 13.12.2023.
//

import SwiftUI

// MARK: - Style

extension TitleAndSubtitleView {
  public enum Style {
    /// Шрифт заголовка
    var fontTitle: Font {
      switch self {
      case .large:
        return .fancy.text.largeTitle
      case .standart:
        return .fancy.text.title
      case .small:
        return .fancy.text.regular
      }
    }
    
    /// Шрифт Описания
    var fontDescription: Font {
      switch self {
      case .large:
        return .fancy.text.regular
      case .standart:
        return .fancy.text.regular
      case .small:
        return .fancy.text.small
      }
    }
    
    /// Большой
    case large
    /// Стандартный
    case standart
    /// Маленький
    case small
  }
}

// MARK: - Model

extension TitleAndSubtitleView {
  public struct Model {
    // MARK: - Public properties
    
    public let text: String
    public let lineLimit: Int
    public let isSelectable: Bool
    public let isSecure: Bool
    public let action: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Инициализатор
    /// - Parameters:
    ///   - text: Текст
    ///   - lineLimit: Количество строк
    ///   - isSelectable: Можно нажать
    ///   - isSecure: Скрытый текст
    ///   - action: Действие на нажатие на текст
    public init(
      text: String,
      lineLimit: Int = .max,
      isSelectable: Bool = false,
      isSecure: Bool = false,
      action: (() -> Void)? = nil
    ) {
      self.text = text
      self.lineLimit = lineLimit
      self.isSelectable = isSelectable
      self.isSecure = isSecure
      self.action = action
    }
  }
}
