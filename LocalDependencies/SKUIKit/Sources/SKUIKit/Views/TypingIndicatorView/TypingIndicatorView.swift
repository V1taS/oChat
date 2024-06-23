//
//  TypingIndicatorView.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 23.06.2024.
//

import Foundation
import SwiftUI
import SKStyle

/// Представление, отображающее анимированный индикатор набора текста.
public struct TypingIndicatorView: View {
  /// Инициализатор представления.
  public init() {}
  
  /// Состояние, управляющее анимацией.
  @State private var isAnimating = false
  
  /// Основное тело представления.
  public var body: some View {
    HStack(spacing: 4) {
      Circle()
        .frame(width: 8, height: 8)
        .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
        .scaleEffect(isAnimating ? 1.0 : 0.5)
        .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true))
      
      Circle()
        .frame(width: 8, height: 8)
        .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
        .scaleEffect(isAnimating ? 1.0 : 0.5)
        .animation(Animation.easeInOut(duration: 0.6).delay(0.2).repeatForever(autoreverses: true))
      
      Circle()
        .frame(width: 8, height: 8)
        .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
        .scaleEffect(isAnimating ? 1.0 : 0.5)
        .animation(Animation.easeInOut(duration: 0.6).delay(0.4).repeatForever(autoreverses: true))
    }
    .onAppear {
      self.isAnimating = true
    }
  }
}

// MARK: - Preview

struct TypingIndicatorView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Spacer()
      TypingIndicatorView()
      Spacer()
    }
    .padding(.top, .s26)
    .padding(.horizontal)
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}
