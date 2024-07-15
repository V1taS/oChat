//
//  Created by Sosin Vitalii on 14.06.2022.
//

import SwiftUI

struct TextInputView: View {
  
  @Environment(\.chatTheme) private var theme
  @EnvironmentObject private var globalFocusState: GlobalFocusState
  
  @Binding var text: String
  var inputFieldId: UUID
  var style: InputViewStyle
  var availableInput: AvailableInputType
  var placeholder: String
  var onChange: (_ newValue: String) -> Void
  let maxLength: Int
  
  var body: some View {
    TextField("", text: $text, axis: .vertical)
      .customFocus($globalFocusState.focus, equals: .uuid(inputFieldId))
      .placeholder(when: text.isEmpty) {
        Text(placeholder)
          .foregroundColor(theme.colors.inputPlaceholder)
      }
      .foregroundColor(theme.colors.inputText)
      .padding(.vertical, 10)
      .padding(.leading, !availableInput.isMediaAvailable ? 12 : 0)
      .onTapGesture {
        globalFocusState.focus = .uuid(inputFieldId)
      }
      .onChange(of: text) { newValue in
        onChange(newValue)
      }
      .onChange(of: text) { newValue in
        if newValue.count > maxLength {
          text = String(newValue.prefix(maxLength))
        }
      }
  }
}
