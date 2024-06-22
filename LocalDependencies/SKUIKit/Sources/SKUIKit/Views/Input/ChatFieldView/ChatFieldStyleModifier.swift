//
//  ChatFieldStyleModifier.swift
//
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI

struct ChatFieldStyleModifier: ViewModifier {
  var style: ChatFieldStyle
  
  func body(content: Content) -> some View {
    content
      .textFieldStyle(textFieldStyle())
  }
  
  private func textFieldStyle() -> some TextFieldStyle {
    switch style {
    case .capsule:
      CapsuleChatFieldStyle()
    }
  }
}
