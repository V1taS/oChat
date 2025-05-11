//
//  ChatView.swift
//  oChat
//
//  10 мая 2025 – перешли на нативное многострочное TextField (iOS 17+).
//  • Компактная «телеграм-style» панель ввода: авто-рост от 1 до ≈ 6 строк
//  • Свёртки (tails) полированы, typing-bubble прибит слева
//

import SwiftUI

struct ChatView: View {
  let friendID: UInt32
  @StateObject private var tox = ToxManager.shared
  @State private var draft = ""

  private var friendMessages: [ChatMessage] {
    tox.messages.filter { $0.friendID == friendID }
                .sorted { $0.timestamp < $1.timestamp }
  }

  var body: some View {
    VStack(spacing: 0) {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(spacing: 8) {
            ForEach(friendMessages) { msg in
              Bubble(message: msg)
                .frame(maxWidth: .infinity,
                       alignment: msg.isOutgoing ? .trailing : .leading)
                .id(msg.id)
            }
            // TODO: live typing-indicator от tox
          }
          .padding(.horizontal)
          .padding(.vertical, 6)
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: friendMessages.count) { _ in
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
          send()
        }
      }
      .fixedSize(horizontal: false, vertical: true)
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(shortAddress).font(.headline)
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        AvatarView(emoji: nil,
                   address: shortAddress,
                   isOnline: true)          // TODO: онлайн-статус из tox
      }
    }
  }

  private var shortAddress: String {
    guard let f = tox.friends.first(where: { $0.id == friendID }) else { return "…" }
    return "\(f.name)"
  }

  private func send() {
    let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else { return }
    tox.sendMessage(to: friendID, text: text)
    draft = ""
  }

  #if canImport(UIKit)
  private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
  #endif
}

// MARK: - UI компоненты (Bubble + InputBar) ---------------------------------------------------------

private struct Bubble: View {
  let message: ChatMessage
  var isOut: Bool { message.isOutgoing }
  private var bubbleFill: AnyShapeStyle {
    isOut
      ? AnyShapeStyle(Color.blue.opacity(0.85))
      : AnyShapeStyle(.ultraThinMaterial)
  }

  var body: some View {
    ZStack(alignment: isOut ? .bottomTrailing : .bottomLeading) {
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(bubbleFill)
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                  .strokeBorder(.gray.opacity(0.15), lineWidth: 0.5))

      Text(message.text)
        .padding(.vertical, 8).padding(.horizontal, 12)
        .foregroundStyle(isOut ? .white : .primary)

      if isOut {
        Checkmarks(delivered: message.isDelivered,
                   read: message.isRead)
          .padding(.horizontal, 4).padding(.bottom, 1)
          .alignmentGuide(.bottom) { $0[.bottom] }
      }
    }
    .fixedSize(horizontal: true, vertical: false)
    .frame(maxWidth: UIScreen.main.bounds.width * 0.6,
           alignment: isOut ? .trailing : .leading)
  }

  private struct Checkmarks: View {
    let delivered: Bool; let read: Bool
    var body: some View {
      if read {
        double(.white)
      } else if delivered {
        double(.white.opacity(0.7))
      } else {
        Image(systemName: "checkmark")
          .font(.caption2).foregroundStyle(.white.opacity(0.7))
      }
    }
    private func double(_ c: Color) -> some View {
      ZStack {
        Image(systemName: "checkmark").offset(x: -3)
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
