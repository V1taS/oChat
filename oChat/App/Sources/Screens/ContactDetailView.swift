//
//  ContactDetailView.swift
//  oChat
//
//  Created by Vitalii Sosin on 11.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

// MARK: - Palette
private enum Palette {
  static let sheetBG   = Color(.systemGroupedBackground)
  static let separator = Color.gray.opacity(0.22)
  static let accentBG  = Color(uiColor: .secondarySystemBackground)
  static let icon      = Color.primary
}

// MARK: - Model
struct ContactTest {
  let id: UUID  = .init()
  let fullName: String
  let lastSeen: String
  let phone: String
  let username: String
  let avatar: Image    // Image("avatar") или AsyncImage
  let media: [MediaItem]
}

struct MediaItem: Identifiable {
  let id = UUID()
  let thumbnail: Image
  let duration: String? // для видео (например "2:57"), для фото nil
}

// MARK: - Экран
struct ContactDetailView: View {
  // MARK: In-memory demo-данные
  private let contact = ContactTest(
    fullName: "Алексей Корнеев",
    lastSeen: "был(а) сегодня в 05:16",
    phone: "+7 925 312 1107",
    username: "@lex58911",
    avatar: Image("playstore"),          // добавьте ресурс в Assets
    media: (0..<15).map { idx in            // примеры превью
      let img = Image("Sample\(idx % 6)")   // 6 заглушек в Assets
      return MediaItem(thumbnail: img, duration: idx.isMultiple(of: 3) ? "2:0\(idx % 10)" : nil)
    })

  // MARK: State
  @State private var selectedTab: Tab = .media

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {

        // MARK: Аватар + имя + статус
        VStack(spacing: 8) {
          contact.avatar
            .resizable()
            .scaledToFill()
            .frame(width: 112, height: 112)
            .clipShape(Circle())

          Text(contact.fullName)
            .font(.title2.weight(.semibold))

          Text(contact.lastSeen)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 12)

        // MARK: Action-кнопки
        actionButtons

        // MARK: Информация (телефон, username)
        infoBlock

        // MARK: Tabs + контент
        VStack(spacing: 14) {
          tabBar
          mediaGrid
        }
      }
      .padding(.horizontal)
      .padding(.bottom, 20)
    }
    .background(Palette.sheetBG.ignoresSafeArea())
    .navigationTitle("")        // пустой, чтобы был крупный заголовок
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Изм.") { /* edit */ }
          .font(.body.weight(.semibold))
      }
    }
    .presentationDetents([.large])
    .presentationDragIndicator(.visible)
  }
}

// MARK: - Sub-components
private extension ContactDetailView {

  // five square buttons
  var actionButtons: some View {
    let buttons: [(String, String)] = [
      ("phone",          "звонок"),
      ("video",          "видео"),
      ("bell.slash",     "звук"),
      ("magnifyingglass","поиск"),
      ("ellipsis",       "ещё")
    ]

    return HStack(spacing: 18) {
      ForEach(buttons, id: \.0) { icon, title in
        VStack(spacing: 6) {
          Image(systemName: icon)
            .font(.title3)
            .frame(width: 56, height: 56)
            .background(Palette.accentBG, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
          Text(title)
            .font(.caption)
        }
        .foregroundStyle(Palette.icon)
        .onTapGesture {
          presentFullScreenWithoutAnimation {
            CallView()
          }
        }
      }
    }
  }

  // phone + username + QR
  var infoBlock: some View {
    VStack(spacing: 0) {
      InfoRow(label: "мобильный",
              value: contact.phone,
              valueColor: .blue,
              showsQR: false)

      divider

      InfoRow(label: "имя пользователя",
              value: contact.username,
              valueColor: .blue,
              showsQR: true)
    }
    .background(.ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .strokeBorder(Palette.separator, lineWidth: 0.5)
    )
  }

  var divider: some View {
    Rectangle()
      .fill(Palette.separator)
      .frame(height: 1 / UIScreen.main.scale)
      .padding(.leading, 18) // отступ под текст
  }

  // MARK: Tabs
  enum Tab: String, CaseIterable {
    case media = "Медиа"
    case files = "Файлы"
    case music = "Музыка"
    case voice = "Голосовые"
    case links = "Ссылки"
    case gif   = "GIF"
  }

  var tabBar: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(Tab.allCases, id: \.self) { tab in
          Button {
            selectedTab = tab
          } label: {
            Text(tab.rawValue)
              .font(.subheadline.weight(.semibold))
              .padding(.vertical, 6)
              .padding(.horizontal, 14)
              .background(selectedTab == tab ? Color.accentColor.opacity(0.15) : Palette.accentBG,
                          in: Capsule())
          }
          .foregroundStyle(selectedTab == tab ? .secondary : .primary)
        }
      }
      .padding(.horizontal, 4)
    }
  }

  // MARK: Media grid
  var mediaGrid: some View {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
      ForEach(contact.media) { item in
        ZStack(alignment: .bottomTrailing) {
          item.thumbnail
            .resizable()
            .scaledToFill()
            .frame(height: 110)
            .clipped()

          if let dur = item.duration {
            Text(dur)
              .font(.caption2.monospacedDigit())
              .padding(.horizontal, 4)
              .padding(.vertical, 2)
              .background(.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
              .foregroundColor(.white)
              .padding(4)
          }
        }
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
  }
}

// MARK: - InfoRow
private struct InfoRow: View {
  let label: String
  let value: String
  let valueColor: Color
  var showsQR: Bool = false

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 12) {
      VStack(alignment: .leading, spacing: 2) {
        Text(label)
          .font(.caption)
          .foregroundStyle(.secondary)
        Text(value)
          .font(.body)
          .foregroundStyle(valueColor)
      }
      Spacer()
      if showsQR {
        Image(systemName: "qrcode")
          .font(.title3)
          .foregroundStyle(Palette.icon)
      }
    }
    .padding(.vertical, 14)
    .padding(.horizontal, 18)
    .contentShape(Rectangle())
  }
}

// MARK: - Preview
#Preview {
  ContactDetailView()
}
