//
//  RoundedColorEdgeView.swift
//
//
//  Created by Vitalii Sosin on 10.12.2023.
//

import SwiftUI
import SKStyle

// MARK: - RoundedColorEdgeView

public struct RoundedColorEdgeView: ViewModifier {
  let backgroundColor: Color
  let boarderColor: Color
  var paddingHorizontal: CGFloat = .s3
  var paddingVertical: CGFloat = .s2
  var cornerRadius: CGFloat = .s4
  
  public func body(content: Content) -> some View {
    content
      .padding(.horizontal, paddingHorizontal)
      .padding(.vertical, paddingVertical)
      .background(backgroundColor)
      .cornerRadius(cornerRadius)
      .overlay(RoundedRectangle(cornerRadius: cornerRadius)
        .stroke(boarderColor))
  }
}

// MARK: - RoundedEdge

extension View {
  public func roundedEdge(
    backgroundColor: Color,
    boarderColor: Color = .clear,
    paddingHorizontal: CGFloat = 12,
    paddingVertical: CGFloat = 8,
    cornerRadius: CGFloat = 16
  ) -> some View {
    self.modifier(
      RoundedColorEdgeView(
        backgroundColor: backgroundColor,
        boarderColor: boarderColor,
        paddingHorizontal: paddingHorizontal,
        paddingVertical: paddingVertical,
        cornerRadius: cornerRadius
      )
    )
  }
}

// MARK: - Preview

struct RoundedColorEdge_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      HStack {
        SKStyleAsset.onyx.swiftUIColor
      }
      
      VStack {
        Text("Copy")
          .roundedEdge(
            backgroundColor: SKStyleAsset.ruby.swiftUIColor,
            boarderColor: .clear
          )
      }
    }
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}