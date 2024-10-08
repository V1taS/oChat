//
//  Created by Sosin Vitalii on 16.06.2022.
//

import SwiftUI

struct AttachmentCell: View {
  
  @Environment(\.chatTheme) private var theme
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  
  let attachment: Attachment
  let onTap: (Attachment) -> Void
  
  var body: some View {
    Group {
      if attachment.type == .image {
        content
      } else if attachment.type == .video {
        content
          .overlay {
            theme.images.message.playVideo
              .resizable()
              .foregroundColor(.white)
              .frame(width: 36, height: 36)
          }
      } else {
        content
          .overlay {
            Text("Unknown")
          }
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      impactFeedback.impactOccurred()
      onTap(attachment)
    }
  }
  
  var content: some View {
    AsyncImageView(url: attachment.thumbnail)
  }
}

struct AsyncImageView: View {
  @Environment(\.chatTheme) var theme
  let url: URL
  
  var body: some View {
    if let imageData = FileManager.default.contents(atPath: url.path()),
       let image = UIImage(data: imageData) {
      Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fill)
    } else {
      ZStack {
        Rectangle()
          .foregroundColor(theme.colors.attachmentImage)
          .frame(minWidth: 100, minHeight: 100)
        ActivityIndicator(size: 30, showBackground: false)
      }
    }
  }
}
