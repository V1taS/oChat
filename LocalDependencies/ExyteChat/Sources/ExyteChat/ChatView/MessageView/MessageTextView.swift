//
//  SwiftUIView.swift
//
//
//  Created by Sosin Vitalii on 07.07.2022.
//

import SwiftUI

struct MessageTextView: View {
  
  let text: String?
  let messageUseMarkdown: Bool
  
  var body: some View {
    if let text = text, !text.isEmpty {
      textView(text)
    }
  }
  
  @ViewBuilder
  private func textView(_ text: String) -> some View {
    if messageUseMarkdown,
       let attributed = try? AttributedString(markdown: text, options: String.markdownOptions) {
      Text(attributed)
    } else {
      Text(text)
    }
  }
}

struct MessageTextView_Previews: PreviewProvider {
  static var previews: some View {
    MessageTextView(text: "Hello world!", messageUseMarkdown: false)
  }
}
