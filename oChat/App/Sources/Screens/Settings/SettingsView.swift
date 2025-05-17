//
//  SettingsView.swift
//  oChat
//
//  Created by Vitalii Sosin on 9.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Palette
private enum Palette {
  static let sheetBG = Color(.systemGroupedBackground)
  static let separator = Color.gray.opacity(0.22)
  static let icon = Color.primary
  static let danger = Color.red
}

// MARK: – View
struct SettingsView: View {
  // MARK: Public API
  let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String

  // MARK: Environment
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var toxManager: ToxManager

  // MARK: – Body
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 28) {

          /// Первая карточка настроек
          VStack(spacing: 0) {
            NavigationLink {
              PrivacySettingsView()
            } label: {
              SettingsRow(icon: "lock", title: "Конфиденциальность")
            }

            divider

            NavigationLink {
              NotificationSettingsView()
            } label: {
              SettingsRow(icon: "bell", title: "Уведомления")
            }

            divider

            NavigationLink {
              RecoveryPasswordView()
            } label: {
              SettingsRow(icon: "shield.lefthalf.filled.badge.checkmark", title: "Пароль восстановления")
            }

            divider

            NavigationLink {
              PremiumView()
            } label: {
              SettingsRow(icon: "star", title: "Премиум")
            }
          }
          .cardStyle

          /// Вторая карточка
          VStack(spacing: 0) {
            NavigationLink {
              HelpView()
            } label: {
              SettingsRow(icon: "questionmark", title: "Помощь")
            }

            divider
            SettingsRow(icon: "trash",
                        iconColor: Palette.danger,
                        title: "Очистить данные",
                        titleColor: Palette.danger)
          }
          .cardStyle

          /// Лого + версия
          VStack(spacing: 12) {
            Image("oChat_in_progress")
              .resizable()
              .scaledToFit()
              .frame(width: 30)
              .opacity(0.5)

            Text("Версия: \(version ?? "")")
              .font(.footnote)
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
      }
      .background(Palette.sheetBG.ignoresSafeArea())
      .navigationTitle("Настройки")
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
    }
  }
}

// MARK: - Row & helpers
private struct SettingsRow: View {
  let icon: String
  var iconColor: Color = Palette.icon
  let title: String
  var titleColor: Color = Palette.icon

  var body: some View {
    HStack(spacing: 20) {
      Image(systemName: icon)
        .font(.body)
        .foregroundStyle(iconColor)
        .frame(width: 26)
      Text(title)
        .font(.body)
        .foregroundStyle(titleColor)
      Spacer()
    }
    .padding(.vertical, 14)
    .padding(.horizontal, 18)
    .contentShape(Rectangle())
    .buttonStyle(.plain)
  }
}

private extension View {
  var divider: some View {
    Rectangle()
      .fill(Palette.separator)
      .frame(height: 1 / UIScreen.main.scale)
  }

  /// Закруглённая карточка со стеклом и обводкой
  var cardStyle: some View {
    self
      .roundedEdge(
        backgroundColor: .clear,
        boarderColor: .clear,
        paddingHorizontal: .zero,
        paddingVertical: 4,
        cornerRadius: 16,
        tintOpacity: 0.1
      )
  }
}

// MARK: – Preview
#Preview {
  SettingsView()
}
