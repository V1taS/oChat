//
//  PasscodeFieldView+Model.swift
//
//
//  Created by Vitalii Sosin on 15.12.2023.
//

import SwiftUI
import SKStyle

// MARK: - Model

extension PasscodeFieldView {
  public enum PasscodeState {
    /// Цвет исходя из состаяния
    var color: Color {
      switch self {
      case .failure:
        return SKStyleAsset.ruby.swiftUIColor
      case .success:
        return SKStyleAsset.lime.swiftUIColor
      case .standart:
        return SKStyleAsset.azure.swiftUIColor
      }
    }
    
    /// Ошибка
    case failure
    /// Успех
    case success
    /// По умолчанию
    case standart
  }
}