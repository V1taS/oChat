//
//  Created by Sosin Vitalii on 20.06.2022.
//

import SwiftUI

struct AttachmentsPage: View {
  @EnvironmentObject var mediaPagesViewModel: FullscreenMediaPagesViewModel
  @Environment(\.chatTheme) private var theme
  
  let attachment: Attachment
  
  @State private var image: UIImage? = nil
  
  var body: some View {
    Group {
      if let image = image {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
      } else if attachment.type == .image {
        ProgressView()
          .onAppear {
            loadImage()
          }
      } else if attachment.type == .video {
        VideoView(viewModel: VideoViewModel(attachment: attachment))
      } else {
        Rectangle()
          .foregroundColor(Color.gray)
          .frame(minWidth: 100, minHeight: 100)
          .frame(maxHeight: 200)
          .overlay {
            Text("Unknown")
          }
      }
    }
  }
  
  private func loadImage() {
    let path = attachment.full.path()
    if let cachedImage = ImageCache().image(forKey: path) {
      self.image = cachedImage
    } else {
      DispatchQueue.global().async {
        if let imageData = FileManager.default.contents(atPath: path),
           let uiImage = UIImage(data: imageData) {
          DispatchQueue.main.async {
            ImageCache().setImage(uiImage, forKey: path)
            self.image = uiImage
          }
        }
      }
    }
  }
}

private final class ImageCache {
  static let shared = NSCache<NSString, UIImage>()
  
  func image(forKey key: String) -> UIImage? {
    return ImageCache.shared.object(forKey: key as NSString)
  }
  
  func setImage(_ image: UIImage, forKey key: String) {
    ImageCache.shared.setObject(image, forKey: key as NSString)
  }
}
