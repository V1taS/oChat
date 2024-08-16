//
//  GalleryHeaderView.swift
//  ExyteChat
//
//  Created by Vitalii Sosin on 14.07.2024.
//

import Foundation
import SwiftUI
import SKStyle

/// View used for the gallery header, for images and videos.
struct GalleryHeaderView: View {
  
  var title: String
  
  @Binding var isShown: Bool
  @Environment(\.chatTheme) private var theme
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  
  var body: some View {
    ZStack {
      HStack {
        Button {
          isShown = false
          impactFeedback.impactOccurred()
        } label: {
          theme.images.mediaPicker.cross
            .resizable()
            .renderingMode(.template)
            .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
            .aspectRatio(contentMode: .fit)
            .frame(height: 24)
        }
        .padding()
        
        Spacer()
      }
      
      VStack {
        Text(title)
          .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
          .font(.fancy.text.regularMedium)
      }
    }
    .frame(height: 32)
  }
}
