//
//  Created by Sosin Vitalii on 07.07.2022.
//

import SwiftUI

struct MessageStatusView: View {
  
  @Environment(\.chatTheme) private var theme
  
  let status: Message.Status
  let onRetry: () -> Void
  
  var body: some View {
    Group {
      switch status {
      case .sending:
        theme.images.message.sending
          .resizable()
          .rotationEffect(.degrees(90))
          .foregroundColor(theme.colors.messageStatus)
      case .sent:
        theme.images.message.checkmarks
          .resizable()
          .foregroundColor(theme.colors.messageStatus)
      case .read:
        theme.images.message.checkmarks
          .resizable()
          .foregroundColor(theme.colors.messageReadStatus)
      case .error:
        Button {
          onRetry()
        } label: {
          theme.images.message.error
            .resizable()
        }
        .foregroundColor(theme.colors.messageErrorStatus)
      }
    }
    .viewSize(MessageView.statusViewSize)
    .padding(.trailing, MessageView.horizontalStatusPadding)
  }
}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      MessageStatusView(status: .sending, onRetry: {})
      MessageStatusView(status: .sent, onRetry: {})
      MessageStatusView(status: .read, onRetry: {})
    }
  }
}
