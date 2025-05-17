//
//  View+If.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

extension View {
  // Функция для условного применения модификатора
  @ViewBuilder
  public func `if`<TrueContent: View, FalseContent: View>(
    _ condition: Bool,
    transform: (Self) -> TrueContent,
    else falseTransform: (Self) -> FalseContent
  ) -> some View {
    if condition {
      transform(self)
    } else {
      falseTransform(self)
    }
  }

  // Определение, когда нет 'else' части
  @ViewBuilder
  public func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
