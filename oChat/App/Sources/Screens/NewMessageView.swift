//
//  NewMessageView.swift
//  oChat
//
//  Created by Vitalii Sosin on 11.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import AVFoundation

// MARK: - Palette
private enum Palette {
  static let sheetBG = Color(.systemGroupedBackground)
  static let separator = Color.gray.opacity(0.22)
  static let accent = Color(red: 0/255, green: 183/255, blue: 241/255) // цвет индикатора
}

// MARK: - Вкладки
private enum InputMode: String, CaseIterable {
  case manual = "Введите Account ID"
  case scanQR = "Сканировать QR-код"
}

// MARK: - Экран
struct NewMessageView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var friendManager: FriendManager

  @State private var selection: InputMode = .manual
  @State private var accountID: String = ""
  @State private var isScanning = false
  @State private var requestMessage: String = ""

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        topTabs
          .padding(.top, 4)

        switch selection {
        case .manual:
          manualEntryView
            .transition(.opacity)
        case .scanQR:
          qrScannerView
            .transition(.opacity)
        }

        Spacer()
      }
      .background(Palette.sheetBG.ignoresSafeArea())
      .navigationTitle("Новое сообщение")
      .navigationBarTitleDisplayMode(.large)
      .onChange(of: selection) { value, _ in
        // запускаем/останавливаем сканер при переключении вкладки
        isScanning = (value == .scanQR)
      }
    }
  }
}

// MARK: - Верхние вкладки
private extension NewMessageView {
  var topTabs: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        ForEach(InputMode.allCases, id: \.self) { mode in
          Button {
            withAnimation(.spring(duration: 0.35)) { selection = mode }
          } label: {
            Text(mode.rawValue)
              .font(.subheadline.weight(.semibold))
              .padding(.vertical, 10)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.plain)
        }
      }

      // Индикатор выбранной вкладки
      GeometryReader { geo in
        Capsule()
          .fill(Palette.accent)
          .frame(width: geo.size.width / 2, height: 3)
          .offset(x: selection == .manual ? 0 : geo.size.width / 2,
                  y: 0)
          .animation(.spring(duration: 0.35), value: selection)
      }
      .frame(height: 3)
    }
  }
}

// MARK: ­– Ручной ввод
private extension NewMessageView {
  var manualEntryView: some View {
    VStack(spacing: 22) {
      // ID
      TextField("Введите Account ID или ONS", text: $accountID, axis: .vertical)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .textFieldStyle(.roundedBorder)
        .padding(.horizontal)
        .padding(.top)

      // Первое сообщение
      TextField("Первая фраза для запроса дружбы (необязательно)",
                text: $requestMessage,
                axis: .vertical)
        .textFieldStyle(.roundedBorder)
        .padding(.horizontal)

      Text("Начните новую беседу, введя ID аккаунта вашего друга, ONS или отсканировав их QR-код. "
           + "Можно сразу написать приветственное сообщение.")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 28)

      Button {
        guard !accountID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        Task {
          await friendManager.addFriend(addressHex: accountID, greeting: requestMessage)
        }
        dismiss()
      } label: {
        Text("Продолжить")
          .font(.headline)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
          .background(Palette.accent)
          .foregroundStyle(.white)
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      }
      .padding(.horizontal, 28)
      .padding(.top, 6)

      Spacer(minLength: 0)
    }
  }
}

// MARK: - Сканер QR-кода / Заглушка для симулятора
private extension NewMessageView {
  @ViewBuilder
  var qrScannerView: some View {

    ZStack {
      ScanQRView { qrCode in
        accountID = qrCode
        selection = .manual
      }
      .ignoresSafeArea()

      // Полупрозрачная маска + рамка
      Color.black.opacity(0.4)
        .mask {
          Rectangle()
            .overlay(
              RoundedRectangle(cornerRadius: 24, style: .continuous)
                .frame(width: 280, height: 280)
                .blendMode(.destinationOut)
            )
        }
        .compositingGroup()

      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .strokeBorder(Color.white.opacity(0.8), lineWidth: 2)
        .frame(width: 280, height: 280)
    }
  }
}

// MARK: – Preview

#Preview {
  NavigationStack {
    NewMessageView()
      .environmentObject(FriendManager.preview)
  }
}
