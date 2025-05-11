//
//  PrivacySettingsView.swift
//  oChat
//
//  Created by Vitalii Sosin on 11.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

// MARK: - Palette
private extension Color {
  /// Цвет карточек – мягкий голубоватый, похожий на скриншот
  static let cardBG    = Color(red: 230/255, green: 247/255, blue: 255/255)
  static let separator = Color.gray.opacity(0.22)
}

/// Общая вью
struct PrivacySettingsView: View {

  // MARK: – Toggles (можно заменить на @AppStorage / ViewModel)
  @State private var voiceVideoEnabled   = true
  @State private var micEnabled          = true
  @State private var cameraEnabled       = true
  @State private var localNetEnabled     = false

  @State private var lockAppEnabled      = false

  @State private var communityReqEnabled = true
  @State private var readReceiptsEnabled = true

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 32) {

          // MARK: Звонки (бета)
          SectionHeader("Звонки (бета)")
          SettingsCard {
            SettingsToggleRow(
              title: "Голосовые и видеозвонки",
              subtitle: "Включает голосовые и видеозвонки для общения с другими пользователями.",
              isOn: $voiceVideoEnabled
            )

            DividerLine()

            SettingsToggleRow(
              title: "Микрофон",
              subtitle: "Allow access to microphone for voice calls and audio messages.",
              isOn: $micEnabled
            )

            DividerLine()

            SettingsToggleRow(
              title: "Камера",
              subtitle: "Allow access to camera for video calls.",
              isOn: $cameraEnabled
            )

            DividerLine()

            SettingsToggleRow(
              title: "Local Network",
              subtitle: "Allow access to local network to facilitate voice and video calls.",
              isOn: $localNetEnabled
            )
          }

          // MARK: Защита экрана
          SectionHeader("Защита экрана")
          SettingsCard {
            SettingsToggleRow(
              title: "Заблокировать приложение",
              subtitle: "Требовать Touch ID, Face ID или ваш пароль для разблокировки oChat.",
              isOn: $lockAppEnabled
            )
          }

          // MARK: Запросы на переписку
          SectionHeader("Запросы на переписку")
          SettingsCard {
            SettingsToggleRow(
              title: "Запросы сообщений сообщества",
              subtitle: "Разрешить возможность отправки приглашений из сообществ.",
              isOn: $communityReqEnabled
            )
          }

          // MARK: Уведомления о прочтении
          SectionHeader("Уведомления о прочтении")
          SettingsCard {
            SettingsToggleRow(
              title: "Уведомления о прочтении",
              subtitle: "Показывать квитанции о прочтении для всех отправляемых и получаемых сообщений.",
              isOn: $readReceiptsEnabled
            )
          }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
      }
      .background(Color(.systemGroupedBackground).ignoresSafeArea())
      .navigationTitle("Конфиденциальность")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .font(.headline)
          }
          .accessibilityLabel("Закрыть")
        }
      }
      .presentationDetents([.large])
      .presentationDragIndicator(.visible)
    }
  }
}

// MARK: - Reusable building blocks
/// Заголовок секции (тонкий серый цвет как в системных настройках)
private struct SectionHeader: View {
  let text: String
  init(_ text: String) { self.text = text }

  var body: some View {
    Text(text)
      .font(.subheadline.weight(.semibold))
      .foregroundStyle(.secondary)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}

/// Карточка-контейнер с скруглённым фоном и обводкой
private struct SettingsCard<Content: View>: View {
  @ViewBuilder var content: Content
  var body: some View {
    VStack(spacing: 0) { content }
      .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(Color.cardBG)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .stroke(Color.separator, lineWidth: 0.5)
      )
  }
}

/// Отдельная строка-переключатель
private struct SettingsToggleRow: View {
  let title: String
  let subtitle: String
  @Binding var isOn: Bool

  var body: some View {
    Toggle(isOn: $isOn) {
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.body)
        Text(subtitle)
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
      .multilineTextAlignment(.leading)
    }
    .toggleStyle(.switch)
    .padding(.vertical, 14)
    .padding(.horizontal, 18)
  }
}

/// Тонкая линия-разделитель (толщина равна 1 px на текущем экране)
private struct DividerLine: View {
  var body: some View {
    Rectangle()
      .fill(Color.separator)
      .frame(height: 1 / UIScreen.main.scale)
      .padding(.leading, 18) // выравниваем с текстом
  }
}

// MARK: - Preview
#Preview {
  PrivacySettingsView()
    .environment(\.locale, .init(identifier: "ru"))
}
