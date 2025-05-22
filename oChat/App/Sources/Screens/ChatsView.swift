//
//  ChatsView.swift
//  oChat
//
//  Created by Vitalii Sosin on 9.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import ToxSwift

struct ChatsView: View {
  @EnvironmentObject var friendManager: FriendManager
  @EnvironmentObject var chatManager: ChatManager
  @EnvironmentObject var connectionManager: ConnectionManager

  @State private var query = ""
  @State private var showSettings = false
  @State private var presentStartConv = false

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: 12) {
          if friendManager.friendRequests.count != .zero {
            NavigationLink {
              FriendRequestsView()
            } label: {
              FriendRequestsBanner(count: friendManager.friendRequests.count)
            }
            .buttonStyle(.plain)
          }

          ForEach(friendManager.friends) { friend in
            let message = chatManager.messages[friend.id]?.last
            NavigationLink(value: friend.id) {
              ChatRow(friendModel: friend, lastMessage: message)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal)
        .padding(.top, 8)
      }
      .background(Color(.systemGroupedBackground))
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button { showSettings = true } label: { Image(systemName: "gearshape") }
            .accessibilityLabel("Настройки")
        }
        ToolbarItem(placement: .principal) {
          ConnectionStatusView(state: connectionManager.connectionState)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button { presentStartConv = true } label: { Image(systemName: "square.and.pencil") }
            .accessibilityLabel("Написать сообщение")
        }
      }
      .navigationDestination(for: UInt32.self) { friendID in
        ChatView(friendID: friendID)
      }
      .sheet(isPresented: $showSettings) {
        SettingsView()
      }
      .sheet(isPresented: $presentStartConv) {
        StartConversationView()
      }
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

// MARK: - Вспомогательные компоненты ---------------------------------------------------------------

private struct ChatRow: View {
  let friendModel: FriendModel
  let lastMessage: ChatMessage?

  var body: some View {
    HStack(spacing: 12) {
      avatarView

      VStack(alignment: .leading, spacing: 6) {
        Text(friendModel.shortAddress).font(.headline).lineLimit(1)

        if friendModel.isTyping {
          TypingIndicator()
        } else {
          Text(lastMessage?.message ?? "Нет сообщений")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineLimit(2)
        }
      }

      Spacer(minLength: 8)
      RightStatus(friendModel: friendModel, lastMessage: lastMessage)
    }
    .roundedEdge(
      paddingHorizontal: 12,
      paddingVertical: 8,
      cornerRadius: 18
    )
  }
}

extension ChatRow {
  var avatarView: some View {
    ZStack {
      // Кружок с цветом + иконкой
      Circle()
        .foregroundColor(friendModel.avatar.color.opacity(0.2))

      switch friendModel.avatar.icon {
      case let .systemSymbol(systemName):
        Image(systemName: systemName)
          .foregroundColor(friendModel.avatar.color)
      case let .customEmoji(emoji):
        Text(emoji)
          .foregroundColor(friendModel.avatar.color)
      }

      Circle().fill(friendModel.connectionState == .online ? .green : .gray)
        .frame(width: 8, height: 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
    .frame(width: 36, height: 36)
  }
}

// статус галочки / бейдж
private struct RightStatus: View {
  let friendModel: FriendModel
  let lastMessage: ChatMessage?

  var body: some View {
    VStack(alignment: .trailing) {
      Spacer()
      if let last = lastMessage, case .outgoing = last.messageType {
        Checkmarks(messageStatus: last.messageStatus)
        EmptyView()
      } else if !friendModel.isTyping, friendModel.unreadCount > 0 {
        UnreadBadge(count: friendModel.unreadCount)
      }
    }
  }

  private struct Checkmarks: View {
    var messageStatus: MessageStatus

    var body: some View {
      switch messageStatus {
      case .sending:
        double(.secondary).accessibilityLabel("Доставлено")
      case .failed:
        EmptyView()
      case .sent:
        double(.secondary).accessibilityLabel("Доставлено")
      case .read:
        double(.blue).accessibilityLabel("Прочитано")
      }
    }
    private func double(_ c: Color) -> some View {
      ZStack {
        Image(systemName: "checkmark").offset(x: -3)
        Image(systemName: "checkmark")
      }
      .font(.caption2).foregroundStyle(c)
    }
  }

  private struct UnreadBadge: View {
    let count: Int
    var body: some View {
      Text("\(count)").font(.caption2.weight(.semibold))
        .roundedEdge(
          backgroundColor: .blue,
          boarderColor: .clear,
          paddingHorizontal: 6,
          paddingVertical: 2,
          paddingBottom: .zero,
          paddingTrailing: .zero,
          cornerRadius: 10,
          tintOpacity: 0.7
        )
        .foregroundStyle(.white)
    }
  }
}

// Индикация подключения
private struct ConnectionStatusView: View {
  let state: ConnectionStatus
  var body: some View {
    HStack(spacing: 4) {
      Circle().fill(color).frame(width: 8, height: 8)
      Text(title).font(.subheadline.weight(.semibold))
    }
    .accessibilityElement(children: .combine)
  }
  private var title: String {
    switch state {

    case .online:
      return "В сети"
    case .offline:
      return "Не в сети"
    case .inProgress:
      return "Подключение"
    }
  }

  private var color: Color {
    switch state {
    case .online:  return .green
    case .inProgress:  return .yellow
    case .offline: return .red
    }
  }
}

private struct FriendRequestsBanner: View {
  let count: Int
  var body: some View {
    HStack {
      Text("Запросы в друзья")
        .font(.headline)
        .foregroundStyle(.primary)
      Spacer()

      Text("\(count)")
        .font(.headline)
        .foregroundStyle(.secondary)
      Image(systemName: "chevron.right")
        .font(.headline.weight(.semibold))
        .foregroundStyle(.secondary)
    }
    .roundedEdge(
      paddingHorizontal: 12,
      paddingVertical: 10,
      cornerRadius: 18
    )
  }
}

#Preview {
  ChatsView()
    .environmentObject(FriendManager.preview)
    .environmentObject(ChatManager.preview)
    .environmentObject(ConnectionManager.preview)
}
