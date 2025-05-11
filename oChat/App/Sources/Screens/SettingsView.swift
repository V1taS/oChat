//
//  SettingsView.swift
//  oChat
//
//  Created by Vitalii Sosin on 10.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Palette
private enum Palette {
  static let sheetBG   = Color(.systemGroupedBackground)
  static let separator = Color.gray.opacity(0.22)
  static let icon      = Color.primary
  static let danger    = Color.red
}

// MARK: – View
struct SettingsView: View {
  // MARK: Public API
  let avatar: Image = Image("oChatLogo")
  let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String

  // Actions
  let onEditNick: () -> Void = {}
  let onShareID: () -> Void = {}
  let onCopyID: () -> Void = {}
  let onPrivacy: () -> Void = {}
  let onNotifications: () -> Void = {}
  let onChats: () -> Void = {}
  let onAppearance: () -> Void = {}
  let onRecoveryPassword: () -> Void = {}
  let onHelp: () -> Void = {}
  let onClearData: () -> Void = {}

  // MARK: Environment
  @Environment(\.dismiss) private var dismiss
  @StateObject private var tox = ToxManager.shared
  @State private var ownAddress = ""

  // MARK: – Body
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 28) {

          /// Аватар + никнейм + ID
          headerBlock
            .padding(.top, 8)

          /// Первая карточка настроек
          VStack(spacing: 0) {
            SettingsRow(icon: "lock",
                        title: "Конфиденциальность",
                        action: onPrivacy)
            divider
            SettingsRow(icon: "bell",
                        title: "Уведомления",
                        action: onNotifications)
            divider
            SettingsRow(icon: "bubble.left.and.text.bubble.right",
                        title: "Беседы",
                        action: onChats)
            divider
            SettingsRow(icon: "paintbrush.pointed",
                        title: "Внешний вид",
                        action: onAppearance)
            divider
            SettingsRow(icon: "shield.lefthalf.filled.badge.checkmark",
                        title: "Пароль восстановления",
                        action: onRecoveryPassword)
          }
          .cardStyle

          /// Вторая карточка
          VStack(spacing: 0) {
            SettingsRow(icon: "questionmark",
                        title: "Помощь",
                        action: onHelp)
            divider
            SettingsRow(icon: "trash",
                        iconColor: Palette.danger,
                        title: "Очистить данные",
                        titleColor: Palette.danger,
                        action: onClearData)
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
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .font(.headline)
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            // «QR-код профиля» – возможно отдельный экран
          } label: {
            Image(systemName: "qrcode")
              .font(.headline)
          }
          .accessibilityLabel("QR-код профиля")
        }
      }
      .task {
        ownAddress = await tox.getOwnAddress()
      }
    }
  }
}

// MARK: - Header
private extension SettingsView {
  var headerBlock: some View {
    VStack(spacing: 14) {
      // Аватар
      avatar
        .resizable()
        .scaledToFill()
        .frame(width: 116, height: 116)
        .clipShape(Circle())
        .overlay { Circle().stroke(Palette.separator, lineWidth: 0.5) }
        .contentShape(Circle())
        .onTapGesture(perform: onEditNick)

      Text("ID вашего аккаунта")
        .font(.footnote.weight(.semibold))
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
        .background(
          Capsule().fill(Color.white)
            .overlay(Capsule().stroke(Palette.separator, lineWidth: 0.5))
        )

      // Сам ID (моноширинный, может быть в 2 строки)
      Text(ownAddress)
        .font(.system(.footnote, design: .monospaced))
        .multilineTextAlignment(.center)
        .lineLimit(3)
        .padding(.horizontal, 24)

      // Кнопки «Поделиться / Скопировать»
      HStack(spacing: 24) {
        CapsuleButton(title: "Поделиться", action: onShareID)
        CapsuleButton(title: "Скопировать", action: onCopyID)
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
  let action: () -> Void

  var body: some View {
    Button(action: action) {
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
    }
    .buttonStyle(.plain)
  }
}

private struct CapsuleButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 28)
        .padding(.vertical, 10)
        .frame(minWidth: 0)
    }
    .buttonStyle(.plain)
    .background(
      Capsule()
        .strokeBorder(Palette.icon, lineWidth: 1)
    )
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
      .background(.ultraThinMaterial,
                  in: RoundedRectangle(cornerRadius: 20, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .stroke(Palette.separator, lineWidth: 0.5)
      )
  }
}

// MARK: – Preview
#Preview {
  SettingsView()
}
