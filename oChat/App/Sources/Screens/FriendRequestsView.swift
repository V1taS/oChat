//
//  FriendRequestsView.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

struct FriendRequestsView: View {
  @EnvironmentObject private var toxManager: ToxManager
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    List {
      ForEach(toxManager.friendRequests) { request in
        FriendRequestRow(request: request)
          .listRowSeparator(.hidden)
      }
    }
    .listStyle(.plain)
    .navigationTitle("Запросы в друзья")
    .navigationBarTitleDisplayMode(.inline)
    .onChange(of: toxManager.friendRequests) { _, newValue in
      if newValue.count == .zero {
        dismiss()
      }
    }
  }
}

// MARK: строка списка
private struct FriendRequestRow: View {
  @EnvironmentObject private var toxManager: ToxManager
  let request: FriendRequest

  var body: some View {
    VStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        Text(request.shortAddress).font(.headline).lineLimit(1)
        if let message = request.message {
          Text(message).font(.caption).foregroundStyle(.secondary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top)

      HStack(spacing: 8) {
        // 1. Принять
        Button {
          Task { await toxManager.acceptFriendRequest(friendRequest: request) }
        } label: {
          Text("Принять")
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)

        // 2. Отклонить
        Button {
          Task { await toxManager.rejectFriendRequest(friendRequest: request) }
        } label: {
          Text("Отклонить")
        }
        .buttonStyle(.bordered)
        .tint(.red)

        // 3. В спам
        Button {
          Task { await toxManager.addToSpamList(request.publicKey) }
        } label: {
          Text("В спам")
        }
        .buttonStyle(.bordered)
        .tint(.orange)
      }
      .padding(.bottom, 2)
    }
    .roundedEdge(
      paddingHorizontal: 12,
      paddingVertical: 8,
      cornerRadius: 18
    )
  }
}

#Preview {
  FriendRequestsView()
    .environmentObject(ToxManager.preview)
}
