//
//  NotificationSettingsView.swift
//  oChat
//
//  Created by Vitalii Sosin on 11.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

// MARK: - Palette
private extension Color {
  static let cardBG    = Color(red: 230/255, green: 247/255, blue: 255/255)
  static let separator = Color.gray.opacity(0.22)
}

// MARK: - View
struct NotificationSettingsView: View {

  // MARK: – States (замените на @AppStorage / ViewModel)
  @State private var fastModeEnabled        = true

  @State private var soundName              = "Note"
  @State private var playSoundWhenForeground = false

  @State private var notificationContent    = "Имя и содержимое"

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 32) {

          // MARK: Метод уведомлений
          SectionHeader("Метод уведомлений")
          SettingsCard {
            SettingsToggleRow(
              title: "Использовать быстрый режим",
              subtitle: "Вы будете получать новые сообщения надёжно и мгновенно через серверы уведомлений Apple.",
              isOn: $fastModeEnabled
            )

            DividerLine()

            SettingsButtonRow(
              title: "Перейти в системные настройки уведомлений"
            ) {
              // TODO: deep-link в системные настройки, если нужно
              if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
              }
            }
          }

          // MARK: Стиль уведомлений
          SectionHeader("Стиль уведомлений")

          // Звук + «звук в фоне»
          SettingsCard {
            SettingsSelectableRow(
              title: "Звук",
              value: soundName
            ) {
              // демонстрационный выбор звука – здесь можно открыть Sheet/меню
              soundName = (soundName == "Note") ? "Ping" : "Note"
            }

            DividerLine()

            SettingsToggleRow(
              title: "Звук, когда приложение открыто",
              subtitle: nil,
              isOn: $playSoundWhenForeground
            )
          }

          // Содержимое уведомления
          SettingsCard {
            SettingsSelectableRow(
              title: "Содержимое уведомления",
              subtitle: "Информация, отображаемая в уведомлениях.",
              value: notificationContent
            ) {
              // демонстрационный цикл вариантов
              notificationContent = switch notificationContent {
              case "Имя и содержимое":  "Только имя"
              case "Только имя":        "Без содержимого"
              default:                  "Имя и содержимое"
              }
            }
          }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
      }
      .background(Color(.systemGroupedBackground).ignoresSafeArea())
      .navigationTitle("Уведомления")
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

// MARK: - Reusable blocks
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

/// Строка-переключатель
private struct SettingsToggleRow: View {
  let title: String
  let subtitle: String?
  @Binding var isOn: Bool

  var body: some View {
    Toggle(isOn: $isOn) {
      VStack(alignment: .leading, spacing: 2) {
        Text(title).font(.body)
        if let subtitle {
          Text(subtitle)
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
      }
      .multilineTextAlignment(.leading)
    }
    .toggleStyle(.switch)
    .padding(.vertical, 14)
    .padding(.horizontal, 18)
  }
}

/// Строка-кнопка (без value)
private struct SettingsButtonRow: View {
  let title: String
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack {
        Text(title)
          .font(.body)
        Spacer()
        Image(systemName: "chevron.right")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(.secondary)
      }
      .contentShape(Rectangle())
      .padding(.vertical, 14)
      .padding(.horizontal, 18)
    }
    .buttonStyle(.plain)
    .foregroundStyle(.primary)
  }
}

/// Строка с выбираемым значением
private struct SettingsSelectableRow: View {
  let title: String
  var subtitle: String? = nil
  let value: String
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text(title).font(.body)
          if let subtitle {
            Text(subtitle)
              .font(.footnote)
              .foregroundStyle(.secondary)
          }
        }
        Spacer()
        Text(value)
          .font(.body)
          .foregroundStyle(.primary)
        Image(systemName: "chevron.down")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(.secondary)
      }
      .contentShape(Rectangle())
      .padding(.vertical, 14)
      .padding(.horizontal, 18)
    }
    .buttonStyle(.plain)
  }
}

/// Тонкая линия-разделитель
private struct DividerLine: View {
  var body: some View {
    Rectangle()
      .fill(Color.separator)
      .frame(height: 1 / UIScreen.main.scale)
      .padding(.leading, 18)
  }
}

// MARK: - Preview
#Preview {
  NotificationSettingsView()
    .environment(\.locale, .init(identifier: "ru"))
}
