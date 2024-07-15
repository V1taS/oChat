//
//  ChatNavigationModifier.swift
//
//
//  Created by Sosin Vitalii on 12.01.2023.
//

import SwiftUI
import SKStyle

/// View used for displaying photos in a grid.
struct GridPhotosView: View {
  
  var attachments: [Attachment]
  @Binding var isShown: Bool
  @StateObject var viewModel: FullscreenMediaPagesViewModel
  @Environment(\.chatTheme) private var theme
  let onSelectMedia: (_ index: Int) -> Void
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  
  private static let spacing: CGFloat = 2
  
  private static var itemWidth: CGFloat {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return (UIScreen.main.bounds.size.width / 3) - spacing * 3
    } else {
      return 120
    }
  }
  
  private let columns = [GridItem(.adaptive(minimum: itemWidth), spacing: spacing)]
  
  var body: some View {
    VStack {
      TitleWithCloseButton(
        title: ExyteChatStrings.gridPhotosHeaderTitle,
        isShown: $isShown
      )
      .frame(height: 48)
      .background(SKStyleAsset.onyx.swiftUIColor)
      
      ScrollView {
        LazyVGrid(columns: columns, spacing: 2) {
          ForEach(attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
            LazyLoadingImage(
              url: attachment.thumbnail,
              width: Self.itemWidth,
              height: Self.itemWidth,
              imageTapped: { index in
                isShown = false
                onSelectMedia(index)
                impactFeedback.impactOccurred()
              },
              index: index
            )
            .frame(
              width: Self.itemWidth,
              height: Self.itemWidth
            )
            .clipped()
            .applyIf(attachment.type == .video) { view in
              view
                .overlay {
                  theme.images.message.playVideo
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                }
            }
          }
        }
        .padding(.horizontal, 2)
        .animation(nil)
      }
      Spacer()
    }
    .background(SKStyleAsset.onyx.swiftUIColor)
  }
}
