//
//  Created by Sosin Vitalii on 02.06.2023.
//

import SwiftUI

struct ThumbnailView: View {
  
#if os(iOS)
  let preview: UIImage?
#else
  // FIXME: Create preview for image/video for other platforms
#endif
  
  var body: some View {
    if let preview = preview {
      GeometryReader { proxy in
        Image(uiImage: preview)
          .resizable()
          .scaledToFill()
          .frame(width: proxy.size.width, height: proxy.size.height)
          .clipped()
      }
    } else {
      ThumbnailPlaceholder()
    }
  }
}
