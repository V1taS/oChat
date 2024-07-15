//
//  MessageMenu.swift
//
//
//  Created by Sosin Vitalii on 20.03.2023.
//

import SwiftUI
import FloatingButton
import enum FloatingButton.Alignment
import SKStyle

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
  var isBottomDirection: Bool
  
  let messageStatus: Message.Status
  var alignment: Alignment
  var leadingPadding: CGFloat
  var trailingPadding: CGFloat
  var mainButton: () -> MainButton
  var onAction: (MessageMenuAction) -> ()
  
  private var buttons: [AnyView] {
    var buttons: [AnyView] = [
      AnyView(
        menuButton(
          title: ExyteChatStrings.messageMenuReplyTitle,
          icon: theme.images.messageMenu.reply,
          action: .reply
        )
      ),
      AnyView(
        menuButton(
          title: ExyteChatStrings.messageMenuCopyTitle,
          icon: theme.images.messageMenu.save,
          action: .copy
        )
      ),
      AnyView(
        menuButton(
          title: ExyteChatStrings.messageMenuDeleteTitle,
          icon: theme.images.messageMenu.delete,
          action: .delete
        )
      )
    ]
    
    if messageStatus == .error {
      buttons.insert(
        AnyView(
          menuButton(
            title: ExyteChatStrings.messageMenuRetryTitle,
            icon: theme.images.messageMenu.retry,
            action: .retry
          )
        ),
        at: .zero
      )
    }
    
    if !isBottomDirection {
      buttons.reverse()
    }
    
    return buttons
  }
  
  var body: some View {
    FloatingButton(mainButtonView: mainButton().allowsHitTesting(false), buttons: buttons, isOpen: $isShowingMenu)
      .straight()
    //.mainZStackAlignment(.top)
      .initialOpacity(0)
      .direction(isBottomDirection ? .bottom : .top)
      .alignment(alignment)
      .spacing(2)
      .animation(.spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.2))
      .menuButtonsSize($menuButtonsSize)
  }
  
  @ViewBuilder
  func menuButton(title: String, icon: Image, action: MessageMenuAction) -> some View {
    let buttonBackgroundColor: Color
    switch action {
    case .retry:
      buttonBackgroundColor = SKStyleAsset.constantLime.swiftUIColor.opacity(0.8)
    case .delete:
      buttonBackgroundColor = SKStyleAsset.constantRuby.swiftUIColor.opacity(0.8)
    default:
      buttonBackgroundColor = SKStyleAsset.constantSlate.swiftUIColor.opacity(0.8)
    }
    
    return HStack(spacing: 0) {
      if alignment == .left {
        Color.clear.viewSize(leadingPadding)
      }
      
      ZStack {
        buttonBackgroundColor
          .background(.ultraThinMaterial)
          .opacity(1)
          .cornerRadius(12)
        
        HStack {
          Text(title)
            .foregroundColor(theme.colors.menuButtonText)
          Spacer()
          icon
            .resizable()
            .renderingMode(.template)
            .foregroundColor(theme.colors.menuButtonText)
            .aspectRatio(contentMode: .fit)
            .frame(width: .s5, height: .s5)
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
