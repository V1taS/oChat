//
//  LazyLoadingImage.swift
//  ExyteChat
//
//  Created by Vitalii Sosin on 14.07.2024.
//

import SwiftUI
import SKStyle

struct LazyLoadingImage: View {
  
  @State private var image: UIImage?
  @State private var error: Error?
  
  let url: URL
  @Environment(\.chatTheme) private var theme
  
  let width: CGFloat
  let height: CGFloat
  var resize: Bool = true
  var shouldSetFrame: Bool = true
  var imageTapped: ((Int) -> Void)? = nil
  var index: Int?
  var onImageLoaded: (UIImage) -> Void = { _ in /* Default implementation. */ }
  
  var body: some View {
    ZStack {
      if let image = image {
        imageView(for: image)
        if let imageTapped = imageTapped {
          // NOTE: needed because of bug with SwiftUI.
          // The click area expands outside the image view (although not visible).
          Rectangle()
            .opacity(0.000001)
            .frame(width: width, height: height)
            .clipped()
            .allowsHitTesting(true)
            .highPriorityGesture(
              TapGesture()
                .onEnded { _ in
                  imageTapped(index ?? 0)
                }
            )
        }
      } else if error != nil {
        Color(.secondarySystemBackground)
      } else {
        ZStack {
          Color(.secondarySystemBackground)
          ProgressView()
        }
      }
    }
    .onAppear {
      if image != nil {
        return
      }
      
      if let imageData = FileManager.default.contents(atPath: url.path()),
         let image = UIImage(data: imageData) {
        self.image = image
        onImageLoaded(image)
      }
    }
  }
  
  func imageView(for image: UIImage) -> some View {
    Image(uiImage: image)
      .resizable()
      .scaledToFill()
      .aspectRatio(contentMode: .fill)
      .frame(width: shouldSetFrame ? width : nil, height: shouldSetFrame ? height : nil)
      .allowsHitTesting(false)
      .scaleEffect(1.0001) // Needed because of SwiftUI sometimes incorrectly displaying landscape images.
      .clipped()
  }
}
