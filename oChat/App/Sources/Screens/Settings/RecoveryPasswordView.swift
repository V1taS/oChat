//
//  RecoveryPasswordView.swift
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

  static let accent    = Color(red: 0/255, green: 183/255, blue: 241/255)
}

// MARK: - View
struct RecoveryPasswordView: View {

  // MARK: – States
  @State private var recoveryPhrase = "gawk dolphin anxiety tilt entrance cell enough rage zebra kennel ultimate alkaline alkaline"
  @State private var showQRSheet    = false
  @State private var isHiddenOnThisDevice = false

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 32) {

          // MARK: Пароль восстановления
          RecoveryCard(
            recoveryPhrase: recoveryPhrase,
            onCopy: copyToPasteboard,
            onShowQR: { showQRSheet = true }
          )

          // MARK: Скрыть пароль восстановления
          HiddenCard(
            isHidden: isHiddenOnThisDevice,
            toggleHide: { isHiddenOnThisDevice.toggle() }
          )
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
      }
      .background(Color(.systemGroupedBackground).ignoresSafeArea())
      .navigationTitle("Пароль восстановления")
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
      .sheet(isPresented: $showQRSheet) {
        // Вставьте сюда генератор QR-кода по вашему вкусу
        VStack(spacing: 24) {
          Text("QR-код пароля восстановления")
            .font(.title3.weight(.semibold))
          // Пример заглушки
          Image(systemName: "qrcode")
            .resizable()
            .scaledToFit()
            .frame(width: 220, height: 220)
            .padding()
          Button("Закрыть", role: .cancel) { showQRSheet = false }
            .font(.headline)
        }
        .presentationDetents([.medium])
      }
      .presentationDetents([.large])
      .presentationDragIndicator(.visible)
    }
  }

  // MARK: – Helpers
  private func copyToPasteboard() {
    UIPasteboard.general.string = recoveryPhrase
    // В реальном приложении покажите Toast / HUD-уведомление об успешном копировании
  }
}

// MARK: - RecoveryCard
private struct RecoveryCard: View {

  let recoveryPhrase: String
  var onCopy: () -> Void
  var onShowQR: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 18) {

      // Заголовок + иконка
      HStack(alignment: .center, spacing: 6) {
        Text("Пароль восстановления")
          .font(.headline)
        Image(systemName: "shield.lefthalf.filled")
          .font(.subheadline)
          .foregroundStyle(.blue)
      }

      // Используйте пароль восстановления, чтобы загрузить свою учётную запись на новых устройствах.\n\nВаша учётная запись не может быть восстановлена без пароля восстановления. Убедитесь, что он хранится в безопасном месте, и не передавайте его никому.

      Text("Используйте пароль восстановления, чтобы загрузить свою учётную запись на новых устройствах.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)

      // Поле с фразой
      Text(recoveryPhrase)
        .font(.callout.monospaced())
        .foregroundStyle(.primary)
        .padding(.vertical, 24)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
          RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(Color.separator, lineWidth: 1)
        )

      // Кнопки
      HStack(spacing: 12) {
        OutlinedButton("Скопировать", action: onCopy)
        OutlinedButton("Посмотреть QR", action: onShowQR)
      }
    }
    .padding(18)
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

// MARK: - HiddenCard
private struct HiddenCard: View {

  let isHidden: Bool
  var toggleHide: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Скрыть Пароль Восстановления")
        .font(.headline)

      Text("Постоянно скрывать ваш пароль восстановления на этом устройстве.")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      HStack {
        Spacer()
        OutlinedButton(
          isHidden ? "Показать" : "Скрыть",
          style: .destructive,
          action: toggleHide
        )
        Spacer()
      }
      .padding(.top, 4)
    }
    .padding(18)
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

// MARK: - OutlinedButton reusable style
private struct OutlinedButton: View {

  enum ButtonKind {
    case normal
    case destructive
  }

  let title: String
  var style: ButtonKind = .normal
  var action: () -> Void

  init(_ title: String, style: ButtonKind = .normal, action: @escaping () -> Void) {
    self.title  = title
    self.style  = style
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.body.weight(.semibold))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
    .buttonStyle(.plain)
    .foregroundStyle(style == .destructive ? Color.red : .accent)
    .overlay(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .stroke(style == .destructive ? Color.red : Color.accent, lineWidth: 1.5)
    )
  }
}

// MARK: - Preview
#Preview {
  RecoveryPasswordView()
    .environment(\.locale, .init(identifier: "ru"))
}
