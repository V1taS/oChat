//
//  Created by Sosin Vitalii on 02.06.2023.
//

import Foundation
import SwiftUI

struct MediaButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration
      .label
      .opacity(configuration.isPressed ? 0.7 : 1.0)
  }
}
