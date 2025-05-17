//
//  ChatView.swift
//  oChat
//
//  Created by Vitalii Sosin on 9.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

struct ChatView: View {
  let friendID: UInt32
  @EnvironmentObject var toxManager: ToxManager
  @State private var draft = ""

  private var friendMessages: [ChatMessage] {
    toxManager.messages[friendID]!.sorted { $0.date < $1.date }
  }

  private var friendModel: FriendModel? {
    guard let idx = toxManager.friends.firstIndex(where: { $0.id == friendID }) else { return nil }
    return toxManager.friends[idx]
  }

  var body: some View {
    VStack(spacing: 0) {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(spacing: 8) {
            ForEach(friendMessages) { msg in
              Bubble(message: msg)
                .frame(maxWidth: .infinity,
                       alignment: msg.messageType == .outgoing ? .trailing : .leading)
                .id(msg.id)
            }
            // TODO: live typing-indicator от tox
          }
          .padding(.horizontal)
          .padding(.vertical, 6)
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: friendMessages.count) { _, _ in
          withAnimation {
            proxy.scrollTo(friendMessages.last?.id, anchor: .bottom)
          }
        }
        .onTapGesture { hideKeyboard() }
      }
    }
    .safeAreaInset(edge: .bottom) {
      VStack(spacing: 0) {
        Divider()
        InputBar(text: $draft) {
          Task {
            await send()
          }
        }
      }
      .fixedSize(horizontal: false, vertical: true)
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        NavigationLink {
          if let friendModel {
            ContactDetailView(friendModel: friendModel)
          }
        } label: {
          Text(friendModel?.shortAddress ?? "")
            .font(.headline)
            .foregroundColor(.primary)
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink {
          if let friendModel {
            ContactDetailView(friendModel: friendModel)
          }
        } label: {
          avatarView
        }
      }
    }
  }

  private func send() async {
    let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else { return }
    await toxManager.sendMessage(to: friendID, text: text)
    draft = ""
  }

  #if canImport(UIKit)
  private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
  #endif
}

extension ChatView {
  var avatarView: some View {
    ZStack {
      // Кружок с цветом + иконкой
      Circle()
        .foregroundColor(friendModel?.avatar.color.opacity(0.2))

      switch friendModel?.avatar.icon ?? .customEmoji("?") {
      case let .systemSymbol(systemName):
        Image(systemName: systemName)
          .foregroundColor(friendModel?.avatar.color)
      case let .customEmoji(emoji):
        Text(emoji)
          .foregroundColor(friendModel?.avatar.color)
      }

      Circle().fill(friendModel?.connectionState == .online ? .green : .gray)
        .frame(width: 8, height: 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
    .frame(width: 36, height: 36)
  }
}

// MARK: - UI компоненты (Bubble + InputBar) ---------------------------------------------------------

private struct Bubble: View {
  let message: ChatMessage
  var isOut: Bool { message.messageType == .outgoing }

  var body: some View {
    HStack(spacing: 4) {
      Text(message.message)
        .foregroundStyle(.primary)

      if isOut {
        MessageStatusView(messageStatus: message.messageStatus)
          .offset(x: 4, y: 6)
      }
    }
    .fixedSize(horizontal: true, vertical: false)
    .roundedEdge(
      backgroundColor: isOut ? .blue : .gray,
      boarderColor: .clear,
      paddingHorizontal: 12,
      paddingVertical: 8,
      cornerRadius: 16,
      tintOpacity: 0.1
    )
    .frame(maxWidth: UIScreen.main.bounds.width * 0.6,
           alignment: isOut ? .trailing : .leading)
  }

  private struct MessageStatusView: View {
    let messageStatus: MessageStatus
    var body: some View {
      switch messageStatus {
      case .sending:
        double(.blue)
      case .failed:
        double(.blue)
      case .sent:
        double(.blue.opacity(0.7))
      case .read:
        double(.blue)
      }
    }
    private func double(_ c: Color) -> some View {
      ZStack {
        Image(systemName: "checkmark").offset(x: -4)
        Image(systemName: "checkmark")
      }.font(.caption2).foregroundStyle(c)
    }
  }
}

private struct InputBar: View {
  @Binding var text: String
  var onSend: () -> Void
  @FocusState private var focused: Bool

  var body: some View {
    HStack(spacing: 8) {
      Image(systemName: "paperclip")
        .font(.system(size: 20))
        .foregroundStyle(Color(.systemGray))

      ZStack {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .stroke(Color(.systemGray4), lineWidth: 1)
          .background(Color.white.cornerRadius(16))

        TextField("", text: $text, axis: .vertical)
          .textFieldStyle(.plain)
          .lineLimit(1...6)
          .padding(.horizontal, 10).padding(.vertical, 6)
          .focused($focused)
      }

      if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        Image(systemName: "mic")
          .font(.system(size: 20))
          .foregroundStyle(Color(.systemGray))
      } else {
        Button {
          onSend(); focused = false
        } label: {
          Image(systemName: "paperplane.fill")
            .font(.system(size: 20))
        }
      }
    }
    .padding(.horizontal).padding(.vertical, 6)
    .background(Color(.systemGroupedBackground).ignoresSafeArea(edges: .bottom))
    .onTapGesture { focused = true }
  }
}

// MARK: – Preview

#Preview {
  NavigationStack {
    ChatView(friendID: 1)
      .environmentObject(ToxManager.preview)
  }
}
