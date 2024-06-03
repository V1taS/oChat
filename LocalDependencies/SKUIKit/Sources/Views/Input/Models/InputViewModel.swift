//
//  InputViewModel.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 03.04.2024.
//

import SwiftUI

// MARK: - Style

@available(iOS 16.0, *)
public struct InputViewModel {
  public let text: String?
  public let placeholder: String
  public let isSecureField: Bool
  public let bottomHelper: String?
  public let isError: Bool
  public let isEnabled: Bool
  public let isTextFieldFocused: Bool
  public let isColorFocusBorder: Bool
  public let keyboardType: UIKeyboardType
  public let maxLength: Int
  public let textFont: Font?
  public let bottomHelperFont: Font?
  public let backgroundColor: Color?
  public let borderColor: Color?
  public let style: InputViewModel.Style
  public let rightButtonType: RightButtonType
  public let rightButtonAction: (() -> Void)?
  public let onChange: ((_ newValue: String) -> Void)?
  public let onTextFieldFocusedChange: ((_ isFocused: Bool, _ text: String) -> Void)?
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - text: Текст, который будет помещен в текстовое поле
  ///   - placeholder: Подсказка для ввода
  ///   - isSecureField: Защищенный режим включен
  ///   - bottomHelper: Текст подсказка снизу
  ///   - isError: Ошибка в поле
  ///   - isEnabled: Текстовое поле включено
  ///   - isTextFieldFocused: Фокус на текстовое поле
  ///   - isColorFocusBorder: Подсвечивать границы при фокусировки текстового поля
  ///   - keyboardType: Стиль клавиатуры
  ///   - maxLength: Максимальная длина символов
  ///   - textFont: Шрифт для текстового поля
  ///   - bottomHelperFont: Шрифт для нижнего хелпера
  ///   - backgroundColor: Цвет фона
  ///   - borderColor: Цвет границы
  ///   - style: Стиль текстового ввода
  ///   - rightButtonType: Стиль правой кнопки
  ///   - rightButtonAction: Акшен по нажатию на кнопку
  ///   - onChange: Акшен на каждый ввод с клавиатуры
  ///   - onTextFieldFocusedChange: Фокус на клавиатуре был изменен
  public init(
    text: String? = nil,
    placeholder: String = "",
    isSecureField: Bool = false,
    bottomHelper: String?,
    isError: Bool = false,
    isEnabled: Bool = true,
    isTextFieldFocused: Bool = false,
    isColorFocusBorder: Bool = true,
    keyboardType: UIKeyboardType = .default,
    maxLength: Int = .max,
    textFont: Font? = nil,
    bottomHelperFont: Font? = nil,
    backgroundColor: Color? = nil,
    borderColor: Color? = nil,
    style: InputViewModel.Style = .none,
    rightButtonType: InputViewModel.RightButtonType = .clear,
    rightButtonAction: (() -> Void)? = nil,
    onChange: ((_ newValue: String) -> Void)? = nil,
    onTextFieldFocusedChange: ((_ isFocused: Bool, _ text: String) -> Void)? = nil
  ) {
    self.text = text
    self.placeholder = placeholder
    self.isSecureField = isSecureField
    self.bottomHelper = bottomHelper
    self.isError = isError
    self.isEnabled = isEnabled
    self.isTextFieldFocused = isTextFieldFocused
    self.isColorFocusBorder = isColorFocusBorder
    self.keyboardType = keyboardType
    self.maxLength = maxLength
    self.textFont = textFont
    self.bottomHelperFont = bottomHelperFont
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
    self.style = style
    self.rightButtonType = rightButtonType
    self.rightButtonAction = rightButtonAction
    self.onChange = onChange
    self.onTextFieldFocusedChange = onTextFieldFocusedChange
  }
}

// MARK: - Style

@available(iOS 16.0, *)
extension InputViewModel {
  public enum RightButtonType: Equatable {
    /// Иконка у кнопки
    var image: Image? {
      switch self {
      case .none:
        return nil
      case .clear:
        return Image(systemName: "xmark.circle.fill")
      case .send:
        return Image(systemName: "arrow.up.circle.fill")
      }
    }
    
    /// Ничего
    case none
    /// Очистить
    case clear
    /// Отправить
    case send(isEnabled: Bool)
  }
}

// MARK: - Style

@available(iOS 16.0, *)
extension InputViewModel {
  public enum Style: Equatable {
    /// Включен хелпер сверху
    var isTopHelper: Bool {
      switch self {
      case .topHelper: return true
      default: return false
      }
    }
    
    /// Слева подсказка
    case leftHelper(text: String)
    
    /// Сверху подсказка
    case topHelper(text: String)
    
    /// Без подсказок
    case none
  }
}
