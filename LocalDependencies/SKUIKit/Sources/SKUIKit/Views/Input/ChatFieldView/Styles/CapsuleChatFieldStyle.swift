//
//  CapsuleChatFieldStyle.swift
//
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKStyle

struct CapsuleChatFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .padding(.vertical, .s2)
      .padding(.horizontal, .s3)
      .textFieldStyle(.plain)
      .clipShape(ClipShape())
      .overlay(ClipShape().stroke(Color(.separator)))
  }
  
  @ViewBuilder
  private func ClipShape() -> some Shape {
    RoundedRectangle(cornerRadius: .s4, style: .continuous)
  }
}
