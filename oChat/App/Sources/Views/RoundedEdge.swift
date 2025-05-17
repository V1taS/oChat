//
//  RoundedColorEdgeView.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

// MARK: - RoundedColorEdgeView

public struct RoundedColorEdgeView: ViewModifier {
  let backgroundColor: Color
  let boarderColor: Color
  var paddingHorizontal: CGFloat
  var paddingVertical: CGFloat
  var paddingBottom: CGFloat
  var paddingTrailing: CGFloat
  var cornerRadius: CGFloat
  var tintOpacity: Double

  public func body(content: Content) -> some View {
    content
      .padding(.horizontal, paddingHorizontal)
      .padding(.vertical, paddingVertical)
      .padding(.bottom, paddingBottom)
      .padding(.trailing, paddingTrailing)
      .background {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .fill(.ultraThinMaterial)
          .overlay(
            backgroundColor == .clear
            ? nil
            : RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
              .fill(backgroundColor.opacity(tintOpacity))
          )
      }
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .stroke(boarderColor)
      )
  }
}

// MARK: - API

public extension View {
  func roundedEdge(
    backgroundColor: Color = .clear,
    boarderColor: Color = .clear,
    paddingHorizontal: CGFloat = 12,
    paddingVertical: CGFloat = 8,
    paddingBottom: CGFloat = .zero,
    paddingTrailing: CGFloat = .zero,
    cornerRadius: CGFloat = 16,
    tintOpacity: Double = 0.1
  ) -> some View {
    modifier(
      RoundedColorEdgeView(
        backgroundColor: backgroundColor,
        boarderColor: boarderColor,
        paddingHorizontal: paddingHorizontal,
        paddingVertical: paddingVertical,
        paddingBottom: paddingBottom,
        paddingTrailing: paddingTrailing,
        cornerRadius: cornerRadius,
        tintOpacity: tintOpacity
      )
    )
  }
}

// MARK: - Preview

struct RoundedColorEdge_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color.white.ignoresSafeArea()

      VStack(spacing: 24) {
        Text("Default material")
          .roundedEdge()

        Text("Tinted material")
          .roundedEdge(
            backgroundColor: .red,
            boarderColor: .red.opacity(0.5)
          )
      }
    }
  }
}
