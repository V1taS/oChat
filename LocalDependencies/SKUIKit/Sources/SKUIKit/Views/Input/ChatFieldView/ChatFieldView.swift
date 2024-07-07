//
//  ChatField.swift
//
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKStyle

/// A SwiftUI view that provides a multiline, editable chat interface.
///
/// ``ChatField`` extends standard text input capabilities by offering multiline text support and is optimized for different platforms .
public struct ChatFieldView<ContentView: View>: View {
  private var titleKey: LocalizedStringKey
  @Binding private var message: String
  
  private var onChange: ((String) -> Void)?
  private var header: (() -> ContentView)?
  private var footer: (() -> ContentView)?
  private let maxLength: Int
  
  public init(
    _ titleKey: LocalizedStringKey,
    message: Binding<String>,
    maxLength: Int = .max,
    onChange: ((String) -> Void)? = nil,
    header: (() -> ContentView)? = nil,
    footer: (() -> ContentView)?
  ) {
    self.titleKey = titleKey
    self._message = message
    self.maxLength = maxLength
    self.onChange = onChange
    self.header = header
    self.footer = footer
  }
  
  public var body: some View {
    VStack(spacing: .s2) {
      if let header = header?() {
        header
      }
      
      TextField(titleKey, text: $message, axis: .vertical)
        .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        .font(.fancy.text.regular)
        .foregroundStyle(.secondary)
        .accentColor(SKStyleAsset.constantAzure.swiftUIColor)
        .lineLimit(5)
      
      if let footer = footer?() {
        footer
      }
    }
    .onChange(of: message) { newValue in
      onChange?(newValue)
    }
    .onChange(of: message) { newValue in
      if newValue.count > maxLength {
        message = String(newValue.prefix(maxLength))
      }
    }
  }
}

// MARK: - Preview

struct ChatFieldView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ChatFieldView("Message", message: .constant("")) { _ in
        EmptyView()
      } footer: {
        Text("Lorem ipsum dolor sit amet.")
      }
      .chatFieldStyle(.capsule)
    }
    .padding()
  }
}
