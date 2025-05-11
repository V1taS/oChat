//
//  TypingIndicator.swift
//  oChat
//
//  Created by Vitalii Sosin on 10.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

// Живой индикатор «Печатает…»
public struct TypingIndicator: View {
  @State private var animate = false

  public var body: some View {
    HStack(spacing: 4) {
      HStack(spacing: 3) {
        ForEach(0..<3) { i in
          Circle()
            .frame(width: 6, height: 6)
            .scaleEffect(animate ? 1 : 0.4)
            .opacity(animate ? 1 : 0.3)
            .animation(
              .easeInOut(duration: 0.6)
              .repeatForever(autoreverses: true)
              .delay(Double(i) * 0.2),
              value: animate
            )
        }
      }
      Text("Печатает").font(.subheadline).foregroundStyle(.secondary)
    }
    .onAppear { animate = true }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Контакт печатает")
  }
}
