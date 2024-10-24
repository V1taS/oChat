//
//  MessageView.swift
//  Chat
//
//  Created by Sosin Vitalii on 23.05.2022.
//

import SwiftUI
import SKStyle

struct MessageView: View {
  
  @Environment(\.chatTheme) private var theme
  
  @ObservedObject var viewModel: ChatViewModel
  
  let message: Message
  let positionInGroup: PositionInGroup
  let chatType: ChatType
  let avatarSize: CGFloat
  let tapAvatarClosure: ChatView.TapAvatarClosure?
  let messageUseMarkdown: Bool
  let isDisplayingMessageMenu: Bool
  let showMessageTimeView: Bool
  
  @State var avatarViewSize: CGSize = .zero
  @State var statusSize: CGSize = .zero
  @State var timeSize: CGSize = .zero
  
  static let widthWithMedia: CGFloat = 204
  static let horizontalNoAvatarPadding: CGFloat = .s4
  static let horizontalAvatarPadding: CGFloat = .s4
  static let horizontalTextPadding: CGFloat = 12
  static let horizontalAttachmentPadding: CGFloat = 1 // for multiple attachments
  static let statusViewSize: CGFloat = 14
  static let horizontalStatusPadding: CGFloat = 8
  static let horizontalBubblePadding: CGFloat = 70
  
  var font: UIFont
  let showMessageName: Bool
  
  enum DateArrangement {
    case hstack, vstack, overlay
  }
  
  var additionalMediaInset: CGFloat {
    message.attachments.count > 1 ? MessageView.horizontalAttachmentPadding * 2 : 0
  }
  
  var dateArrangement: DateArrangement {
    let timeWidth = timeSize.width + 10
    let textPaddings = MessageView.horizontalTextPadding * 2
    let widthWithoutMedia = UIScreen.main.bounds.width
    - (message.user.isCurrentUser ? MessageView.horizontalNoAvatarPadding : avatarViewSize.width)
    - statusSize.width
    - MessageView.horizontalBubblePadding
    - textPaddings
    
    let maxWidth = message.attachments.isEmpty ? widthWithoutMedia : MessageView.widthWithMedia - textPaddings
    let finalWidth = message.text.width(withConstrainedWidth: maxWidth, font: font, messageUseMarkdown: messageUseMarkdown)
    let lastLineWidth = message.text.lastLineWidth(labelWidth: maxWidth, font: font, messageUseMarkdown: messageUseMarkdown)
    let numberOfLines = message.text.numberOfLines(labelWidth: maxWidth, font: font, messageUseMarkdown: messageUseMarkdown)
    
    if numberOfLines == 1, finalWidth + CGFloat(timeWidth) < maxWidth {
      return .hstack
    }
    if lastLineWidth + CGFloat(timeWidth) < finalWidth {
      return .overlay
    }
    return .vstack
  }
  
  var showAvatar: Bool {
    positionInGroup == .single
    || (chatType == .chat && positionInGroup == .last)
    || (chatType == .comments && positionInGroup == .first)
  }
  
  var topPadding: CGFloat {
    if chatType == .comments { return 0 }
    return positionInGroup == .single || positionInGroup == .first ? 8 : 4
  }
  
  var bottomPadding: CGFloat {
    if chatType == .chat { return 0 }
    return positionInGroup == .single || positionInGroup == .first ? 8 : 4
  }
  
  var body: some View {
    HStack(alignment: .bottom, spacing: 0) {
      VStack(alignment: message.user.isCurrentUser ? .trailing : .leading, spacing: 2) {
        if let countEmojis = countEmojis(in: message.text), countEmojis != .zero {
          Text(message.text)
            .font(.system(size: countEmojis == 1 ? .s20 : .s15))
        } else {
          bubbleView(message)
        }
      }
      
      if message.user.isCurrentUser {
        MessageStatusView(status: message.status)
          .sizeGetter($statusSize)
      }
    }
    .padding(.top, topPadding)
    .padding(.bottom, bottomPadding)
    .padding(.leading, .s4)
    .padding(.trailing, .s2)
    .padding(message.user.isCurrentUser ? .leading : .trailing, MessageView.horizontalBubblePadding)
    .frame(maxWidth: UIScreen.main.bounds.width, alignment: message.user.isCurrentUser ? .trailing : .leading)
  }
  
  @ViewBuilder
  func bubbleView(_ message: Message) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      if showMessageName && !message.user.isCurrentUser {
        nameBubbleView(message)
          .padding(.top, .s2)
      }
      
      if !isDisplayingMessageMenu, let reply = message.replyMessage?.toMessage() {
        replyBubbleView(reply)
          .padding(.horizontal, .s2)
          .padding(.top, .s2)
      }
      
      if !message.attachments.isEmpty {
        attachmentsView(message)
      }
      
      if !message.text.isEmpty {
        textWithTimeView(message)
          .font(Font(font))
      }
      
      if let recording = message.recording {
        VStack(alignment: .trailing, spacing: 8) {
          recordingView(recording)
          messageTimeView()
            .padding(.bottom, 8)
            .padding(.trailing, 12)
        }
      }
    }
    .bubbleBackground(message, theme: theme, isSystemMessage: message.isSystemMessage)
  }
  
  @ViewBuilder
  func replyBubbleView(_ message: Message) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      if !message.text.isEmpty {
        MessageTextView(text: message.text, messageUseMarkdown: messageUseMarkdown)
          .padding(.horizontal, MessageView.horizontalTextPadding)
      }
    }
    .font(.caption2)
    .padding(.vertical, .s1)
    .bubbleBackground(
      message,
      theme: theme,
      foregroundColor: SKStyleAsset.ghost.swiftUIColor,
      background: SKStyleAsset.onyx.swiftUIColor.opacity(0.5),
      radius: .s2
    )
  }
  
  @ViewBuilder
  func nameBubbleView(_ message: Message) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      MessageTextView(text: message.user.name, messageUseMarkdown: messageUseMarkdown)
        .lineLimit(1)
        .foregroundColor(.colorFromString(message.user.name))
        .padding(.horizontal, MessageView.horizontalTextPadding)
    }
    .fontWeight(.medium)
    .font(.footnote)
  }
  
  @ViewBuilder
  var avatarView: some View {
    if showAvatar {
      Group {
        AvatarView(url: message.user.avatarURL, avatarSize: avatarSize)
          .contentShape(Circle())
          .onTapGesture {
            tapAvatarClosure?(message.user, message.id)
          }
      }
      .padding(.horizontal, MessageView.horizontalAvatarPadding)
      .sizeGetter($avatarViewSize)
    }
  }
  
  @ViewBuilder
  func attachmentsView(_ message: Message) -> some View {
    AttachmentsGrid(attachments: message.attachments) {
      viewModel.presentAttachmentFullScreen($0)
    }
    .applyIf(message.attachments.count > 1) {
      $0
        .padding(.top, MessageView.horizontalAttachmentPadding)
        .padding(.horizontal, MessageView.horizontalAttachmentPadding)
    }
    .overlay(alignment: .bottomTrailing) {
      if message.text.isEmpty {
        messageTimeView(needsCapsule: true)
          .padding(4)
      }
    }
    .contentShape(Rectangle())
  }
  
  @ViewBuilder
  func textWithTimeView(_ message: Message) -> some View {
    let messageView = MessageTextView(text: message.text, messageUseMarkdown: messageUseMarkdown)
      .fixedSize(horizontal: false, vertical: true)
      .padding(.horizontal, MessageView.horizontalTextPadding)
    
    let timeView = messageTimeView()
      .padding(.trailing, 12)
    
    Group {
      switch dateArrangement {
      case .hstack:
        HStack(alignment: .lastTextBaseline, spacing: 12) {
          messageView
          if !message.attachments.isEmpty {
            Spacer()
          }
          timeView
        }
        .padding(.vertical, 8)
      case .vstack:
        VStack(alignment: .leading, spacing: 4) {
          messageView
          HStack(spacing: 0) {
            Spacer()
            timeView
          }
        }
        .padding(.vertical, 8)
      case .overlay:
        messageView
          .padding(.vertical, 8)
          .overlay(alignment: .bottomTrailing) {
            timeView
              .padding(.vertical, 8)
          }
      }
    }
  }
  
  @ViewBuilder
  func recordingView(_ recording: Recording) -> some View {
    RecordWaveformWithButtons(
      recording: recording,
      colorButton: SKStyleAsset.constantOnyx.swiftUIColor.opacity(0.5),
      colorButtonBg: SKStyleAsset.constantOnyx.swiftUIColor.opacity(0.3),
      colorWaveform: SKStyleAsset.constantOnyx.swiftUIColor.opacity(0.3)
    )
    .padding(.horizontal, MessageView.horizontalTextPadding)
    .padding(.vertical, 8)
  }
  
  func messageTimeView(needsCapsule: Bool = false) -> some View {
    Group {
      if showMessageTimeView {
        if needsCapsule {
          MessageTimeWithCapsuleView(text: message.time, isCurrentUser: message.user.isCurrentUser, chatTheme: theme)
        } else {
          MessageTimeView(text: message.time, isCurrentUser: message.user.isCurrentUser, chatTheme: theme)
        }
      }
    }
    .sizeGetter($timeSize)
  }
}

extension View {
  @ViewBuilder
  func bubbleBackground(
    _ message: Message,
    theme: ChatTheme,
    isSystemMessage: Bool = false,
    foregroundColor: Color? = nil,
    background: Color? = nil,
    radius: CGFloat? = nil
  ) -> some View {
    let radius: CGFloat =  radius ?? (!message.attachments.isEmpty ? 12 : 20)
    let additionalMediaInset: CGFloat = message.attachments.count > 1 ? 2 : 0
    self
      .frame(width: message.attachments.isEmpty ? nil : MessageView.widthWithMedia + additionalMediaInset)
      .foregroundColor(
        foregroundColor ??
        (isSystemMessage ? theme.colors.systemMessageBubbleText :
          message.user.isCurrentUser ? theme.colors.myMessageBubbleText : theme.colors.friendMessageBubbleText)
      )
      .background {
        if !message.text.isEmpty || message.recording != nil {
          RoundedRectangle(cornerRadius: radius)
            .foregroundColor(
              background ??
              (isSystemMessage ? theme.colors.systemMessageBubbleBackground :
                message.user.isCurrentUser ? theme.colors.myMessageBubbleBackground : theme.colors.friendMessageBubbleBackground)
            )
        }
      }
      .cornerRadius(radius)
  }
}

#if DEBUG
struct MessageView_Preview: PreviewProvider {
  static let stan = User(id: "stan", name: "Stan", avatarURL: nil, isCurrentUser: false)
  static let john = User(id: "john", name: "John", avatarURL: nil, isCurrentUser: true)
  
  static private var shortMessage = "Hi, buddy!"
  static private var longMessage = "Hello hello hello hello hello hello hello hello hello hello hello hello hello\n hello hello hello hello d d d d d d d d"
  
  static private var replyedMessage = Message(
    id: UUID().uuidString,
    user: stan,
    status: .read,
    isSystemMessage: false,
    text: longMessage,
    attachments: [
      Attachment.randomImage(),
      Attachment.randomImage(),
      Attachment.randomImage(),
      Attachment.randomImage(),
      Attachment.randomImage(),
    ]
  )
  
  static private var message = Message(
    id: UUID().uuidString,
    user: stan,
    status: .read,
    isSystemMessage: false,
    text: shortMessage,
    replyMessage: replyedMessage.toReplyMessage()
  )
  
  static var previews: some View {
    ZStack {
      Color.yellow.ignoresSafeArea()
      
      MessageView(
        viewModel: ChatViewModel(),
        message: replyedMessage,
        positionInGroup: .single,
        chatType: .chat,
        avatarSize: 32,
        tapAvatarClosure: nil,
        messageUseMarkdown: false,
        isDisplayingMessageMenu: false,
        showMessageTimeView: true,
        font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15)),
        showMessageName: true
      )
    }
  }
}
#endif

// MARK: - Private

private extension MessageView {
  func countEmojis(in string: String) -> Int? {
    let isNumber: (Character) -> Bool = { $0.unicodeScalars.allSatisfy { $0.properties.numericType != nil } }
    let isEmoji: (Character) -> Bool = { $0.unicodeScalars.first?.properties.isEmojiPresentation ?? false }
    
    // Проверяем, состоит ли строка только из цифр
    let allNumbers = string.allSatisfy(isNumber)
    if (allNumbers) {
      return nil
    }
    
    let emojiCount = string.filter(isEmoji).count
    return emojiCount == string.count ? emojiCount : nil
  }
}

// MARK: - ContainsOnlyEmojis

private extension String {
  var containsOnlyEmojis: Bool {
    return !self.isEmpty && self.allSatisfy { $0.isEmoji }
  }
}

// MARK: - IsEmoji

private extension Character {
  var isEmoji: Bool {
    // Проверка, что символ является смайлом по Unicode свойствам
    return self.unicodeScalars.allSatisfy { $0.properties.isEmojiPresentation || $0.properties.isEmoji }
  }
}
