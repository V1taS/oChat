//
//  ChatsView.swift
//  oChat
//
//  Redesigned on 10.05.2025 – modern, privacy-first look.
//  Updated on 10.05.2025 – added connection status in the centre of the navigation bar
//                           and a leading gear button that opens Settings.
//  Fixed on 10.05.2025 – typing indicator animation + “Печатает” label.
//

import SwiftUI
import ToxSwift

struct ChatsView: View {
  @StateObject private var tox = ToxManager.shared
  @State private var query = ""
  @State private var showSettings = false
  @State private var presentStartConv = false

  private var filtered: [ChatSummary] {
    if query.isEmpty { return tox.chatSummaries }
    return tox.chatSummaries.filter {
      $0.shortAddress.localizedCaseInsensitiveContains(query) ||
      ($0.lastMessage?.preview ?? "").localizedCaseInsensitiveContains(query)
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(filtered) { chat in
            NavigationLink(value: chat.id) {
              ChatRow(chat: chat)
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
          ConnectionStatusView(state: tox.dhtConnectionState)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button { presentStartConv = true } label: { Image(systemName: "square.and.pencil") }
            .accessibilityLabel("Написать сообщение")
        }
      }
      .navigationDestination(for: UInt32.self) { friendID in
        ChatView(friendID: friendID)
      }
      .searchable(text: $query, placement: .navigationBarDrawer, prompt: "Поиск")
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
  let chat: ChatSummary

  var body: some View {
    HStack(spacing: 12) {
      AvatarView(emoji: chat.contactEmoji, address: chat.address, isOnline: chat.isOnline)

      VStack(alignment: .leading, spacing: 6) {
        Text(chat.shortAddress).font(.headline).lineLimit(1)

        if chat.isTyping {
          TypingIndicator()
        } else {
          Text(chat.lastMessage?.preview ?? "Нет сообщений")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineLimit(2)
        }
      }

      Spacer(minLength: 8)
      RightStatus(chat: chat)
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 12)
    .background(.ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
      .strokeBorder(Color.gray.opacity(0.15), lineWidth: 0.5))
  }
}

// статус галочки / бейдж
private struct RightStatus: View {
  let chat: ChatSummary

  var body: some View {
    VStack(alignment: .trailing) {
      Spacer()
      if let last = chat.lastMessage, last.isOutgoing,
         case .text = last.kind {
        Checkmarks(delivered: last.isDelivered, read: last.isRead)
      } else if !chat.isTyping, chat.unreadCount > 0 {
        UnreadBadge(count: chat.unreadCount)
      }
    }
  }

  private struct Checkmarks: View {
    let delivered: Bool; let read: Bool
    var body: some View {
      if read {
        double(.blue).accessibilityLabel("Прочитано")
      } else if delivered {
        double(.secondary).accessibilityLabel("Доставлено")
      } else {
        Image(systemName: "checkmark")
          .font(.caption2).foregroundStyle(.secondary)
          .accessibilityLabel("Отправлено")
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
      Text("\(count)") .font(.caption2.weight(.semibold))
        .padding(.horizontal, 6).padding(.vertical, 2)
        .background(Capsule().fill(.blue)).foregroundStyle(.white)
        .accessibilityLabel("\(count) непрочитанных")
    }
  }
}

// Индикация подключения
private struct ConnectionStatusView: View {
  let state: ConnectionState
  var body: some View {
    HStack(spacing: 4) {
      Circle().fill(color).frame(width: 8, height: 8)
      Text(title).font(.subheadline.weight(.semibold))
    }
    .accessibilityElement(children: .combine)
  }
  private var title: String {
    switch state {
    case .tcp:  return "В сети"
    case .udp:  return "UDP-режим"
    case .none: return "Не в сети"
    }
  }

  private var color: Color {
    switch state {
    case .tcp:  return .green
    case .udp:  return .yellow
    case .none: return .red
    }
  }
}
