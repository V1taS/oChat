//
//  ChatField+ChatFieldStyle.swift
//
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI

extension ChatFieldView {
  public func chatFieldStyle(_ style: ChatFieldStyle) -> some View {
    self.modifier(ChatFieldStyleModifier(style: style))
  }
}
