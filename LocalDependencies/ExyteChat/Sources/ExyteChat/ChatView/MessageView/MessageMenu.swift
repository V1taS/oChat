//
//  MessageMenu.swift
//
//
//  Created by Sosin Vitalii on 20.03.2023.
//

import SwiftUI
import FloatingButton
import enum FloatingButton.Alignment

enum MessageMenuAction {
  case reply
  case retry
  case delete
  case copy
}

struct MessageMenu<MainButton: View>: View {
  
  @Environment(\.chatTheme) private var theme
  
  @Binding var isShowingMenu: Bool
  @Binding var menuButtonsSize: CGSize
  
  let messageStatus: Message.Status
  var alignment: Alignment
  var leadingPadding: CGFloat
  var trailingPadding: CGFloat
  var mainButton: () -> MainButton
  var onAction: (MessageMenuAction) -> ()
  
  private var buttons: [AnyView] {
    var buttons: [AnyView] = [
      AnyView(menuButton(title: "Reply", icon: theme.images.messageMenu.reply, action: .reply)),
      AnyView(menuButton(title: "Delete", icon: theme.images.messageMenu.delete, action: .delete)),
      AnyView(menuButton(title: "Copy", icon: theme.images.messageMenu.save, action: .copy))
    ]
    
    if messageStatus == .error {
      buttons.insert(AnyView(menuButton(title: "Retry", icon: theme.images.messageMenu.retry, action: .retry)), at: .zero)
    }
    return buttons
  }
  
  var body: some View {
    FloatingButton(mainButtonView: mainButton().allowsHitTesting(false), buttons: buttons, isOpen: $isShowingMenu)
    .straight()
    //.mainZStackAlignment(.top)
    .initialOpacity(0)
    .direction(.bottom)
    .alignment(alignment)
    .spacing(2)
    .animation(.linear(duration: 0.2))
    .menuButtonsSize($menuButtonsSize)
  }
  
  func menuButton(title: String, icon: Image, action: MessageMenuAction) -> some View {
    HStack(spacing: 0) {
      if alignment == .left {
        Color.clear.viewSize(leadingPadding)
      }
      
      ZStack {
        theme.colors.menuButtonBackground
          .background(.ultraThinMaterial)
          .opacity(0.5)
          .cornerRadius(12)
        HStack {
          Text(title)
            .foregroundColor(theme.colors.menuButtonText)
          Spacer()
          icon
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 12)
      }
      .frame(width: 208)
      .fixedSize()
      .onTapGesture {
        onAction(action)
      }
      
      if alignment == .right {
        Color.clear.viewSize(trailingPadding)
      }
    }
  }
}
