//
//  TitleWithCloseButton.swift
//  ExyteChat
//
//  Created by Vitalii Sosin on 14.07.2024.
//

import SwiftUI
import SKStyle

/// View displaying a title and a close button.
struct TitleWithCloseButton: View {
  
  var title: String
  @Binding var isShown: Bool
  @Environment(\.chatTheme) private var theme
  
  var body: some View {
    ZStack {
      HStack {
        Spacer()
        
        Button {
          isShown = false
        } label: {
          theme.images.mediaPicker.cross
            .resizable()
            .renderingMode(.template)
            .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
            .aspectRatio(contentMode: .fit)
            .frame(height: 24)
        }
        .padding()
      }
      
      Text(title)
        .font(.fancy.text.regular)
    }
    .padding()
  }
}
