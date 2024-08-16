//
//  Created by Sosin Vitalii on 02.06.2023.
//

import SwiftUI

struct ThumbnailPlaceholder: View {
  
  var body: some View {
    Rectangle()
      .fill(.gray.opacity(0.3))
      .aspectRatio(1, contentMode: .fill)
  }
}
