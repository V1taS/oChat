//
//  CustomSheetView.swift
//
//
//  Created by Vitalii Sosin on 26.02.2024.
//

import SwiftUI
import SKFoundation
import SKStyle

public struct CustomSheetView<Content: View>: View {
  
  // MARK: - Private properties
  
  private let content: () -> Content
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - content: Контент
  public init(
    content: @escaping () -> Content
  ) {
    self.content = content
  }
  
  public var body: some View {
    VStack(spacing: .zero) {
      SKStyleAsset.constantSlate.swiftUIColor
        .frame(width: .s11, height: .s1)
        .cornerRadius(.s1)
        .padding(.top, .s2)
      
      content()
        .padding(.top, .s4)
      
      Spacer()
    }
    .padding(.horizontal, .s4)
    .presentationDragIndicator(.hidden)
  }
}
