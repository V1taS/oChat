//
//  Created by Sosin Vitalii on 20.06.2022.
//

import SwiftUI

struct AttachmentsPage: View {
  
  @EnvironmentObject var mediaPagesViewModel: FullscreenMediaPagesViewModel
  @Environment(\.chatTheme) private var theme
  
  let attachment: Attachment
  
  var body: some View {
    if attachment.type == .image,
       let imageData = FileManager.default.contents(atPath: attachment.full.path()),
       let image = UIImage(data: imageData) {
      Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fill)
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
