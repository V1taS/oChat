//
//  TipsView+Model.swift
//
//
//  Created by Vitalii Sosin on 24.01.2024.
//

import SwiftUI
import SKStyle

// MARK: - Style

extension TipsView {
  public enum Style {
    
    /// Цвет фона
    var backgroundColor: Color {
      let opacity: CGFloat = 0.8
      switch self {
      case .danger:
        return SKStyleAsset.constantRuby.swiftUIColor.opacity(opacity)
      case .attention:
        return SKStyleAsset.constantAmberGlow.swiftUIColor.opacity(opacity)
      case .success:
        return SKStyleAsset.constantLime.swiftUIColor.opacity(opacity)
      }
    }
    
    /// Опасность
    case danger
    /// Внимание
    case attention
    /// Успех
    case success
  }
}

// MARK: - Model

extension TipsView {
  public struct Model {
    
    // MARK: - Public properties
    
    public let text: String
    public let style: Style
    public let isSelectableTips: Bool
    public let actionTips: (() -> Void)?
    public let isCloseButton: Bool
    public let closeButtonAction: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Инициализатор
    /// - Parameters:
    ///   - text: Текст
    ///   - style: Стиль подсказки
    ///   - isSelectableTips: На подсказку можно нажимать
    ///   - actionTips: Действие при нажатии на подсказку
    ///   - isCloseButton: Включена кнопка закрыть
    ///   - closeButtonAction: Действие на нажатие на кнопку закрыть
    public init(
      text: String,
      style: TipsView.Style,
      isSelectableTips: Bool = false,
      actionTips: (() -> Void)? = nil,
      isCloseButton: Bool = false,
      closeButtonAction: (() -> Void)? = nil
    ) {
      self.text = text
      self.style = style
      self.isSelectableTips = isSelectableTips
      self.actionTips = actionTips
      self.isCloseButton = isCloseButton
      self.closeButtonAction = closeButtonAction
    }
  }
}
