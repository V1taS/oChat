//
//  StartConversationView.swift
//  oChat
//
//  Created by Vitalii Sosin on 9.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Palette
private enum Palette {
  static let sheetBG   = Color(.systemGroupedBackground)
  static let separator = Color.gray.opacity(0.22)
  static let icon = Color.primary
}

// MARK: - Экран
struct StartConversationView: View {

  // MARK: Environment
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var toxManager: ToxManager
  @State private var ownAddress = ""
  @State private var showScanQR = false

  // MARK: - Body
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .center, spacing: 28) {
          actionsBlock
          idAndQRBlock
            .padding(.horizontal)
          Spacer(minLength: 12)
        }
        .padding(.top, 12)
        .padding(.bottom, 16)
      }
      .background(Palette.sheetBG.ignoresSafeArea())
      .navigationTitle("Начать беседу")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showScanQR = true
          } label: {
            Image(systemName: "qrcode")
              .font(.headline)
          }
          .accessibilityLabel("QR-код профиля")
        }
      }
      .sheet(isPresented: $showScanQR) {
        ScanQRView()
      }
      .task {
        ownAddress = await toxManager.getOwnAddress()
      }
    }
    .presentationDetents([.large])
    .presentationDragIndicator(.visible)
  }
}

// MARK: - Sub-views
private extension StartConversationView {
  // Список действий
  var actionsBlock: some View {
    VStack(spacing: 0) {

      NavigationLink {
        NewMessageView()
      } label: {
        ActionRow(icon: "bubble.left.and.bubble.right", title: "Новое сообщение")
      }

      divider

      NavigationLink {
        CreateGroupView()
      } label: {
        ActionRow(icon: "person.3", title: "Создать группу")
      }

      divider
      ActionRow(icon: "person.badge.plus", title: "Пригласить друга")
    }
    .roundedEdge(
      backgroundColor: .clear,
      boarderColor: .clear,
      paddingHorizontal: .zero,
      paddingVertical: 4,
      cornerRadius: 16,
      tintOpacity: 0.1
    )
    .padding(.horizontal)
  }

  // ID + QR-код
  var idAndQRBlock: some View {
    VStack(alignment: .center, spacing: 14) {
      Text("ID вашего аккаунта")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)

      Text("Друзья могут отправить вам сообщение")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)

      // QR-код + логотип
      ZStack {
        qrImage
          .interpolation(.none)
          .resizable()
          .scaledToFit()

        Image("oChatLogo")
          .resizable()
          .scaledToFit()
          .frame(width: 56, height: 56)
          .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
      }
      .frame(maxWidth: 240)
      .padding(10)
      .background(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(Color.white)
          .shadow(radius: 2, y: 1)
      )
      .accessibilityLabel("QR-код вашей учётной записи")

      // Сам ID (моноширинный, может быть в 2 строки)
      Text(ownAddress)
        .font(.system(.footnote, design: .monospaced))
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
        .lineLimit(3)
        .roundedEdge(
          backgroundColor: .gray,
          boarderColor: .clear,
          paddingHorizontal: 12,
          paddingVertical: 4,
          cornerRadius: 16,
          tintOpacity: 0.1
        )
        .padding(.horizontal)

      // Кнопки «Поделиться / Скопировать»
      HStack(spacing: 24) {
        TapGestureView(
          style: .flash,
          touchesEnded: {
            UIPasteboard.general.string = ownAddress
            NotificationService.shared.showPositiveAlertWith(title: "Скопирован в буффер")
          }
        ) {
          Text("Поделиться")
            .roundedEdge(
              backgroundColor: .gray,
              boarderColor: .clear,
              paddingHorizontal: 12,
              paddingVertical: 4,
              cornerRadius: 16,
              tintOpacity: 0.1
            )
        }

        TapGestureView(
          style: .flash,
          touchesEnded: {
            // TODO: -
          }
        ) {
          Text("Скопировать")
            .roundedEdge(
              backgroundColor: .gray,
              boarderColor: .clear,
              paddingHorizontal: 12,
              paddingVertical: 4,
              cornerRadius: 16,
              tintOpacity: 0.1
            )
        }
      }
    }
  }

  var divider: some View {
    Rectangle()
      .fill(Palette.separator)
      .frame(height: 1 / UIScreen.main.scale)
  }
}

// MARK: - ActionRow
private struct ActionRow: View {
  let icon: String
  let title: String

  var body: some View {
    HStack(spacing: 18) {
      Image(systemName: icon)
        .font(.body)
        .frame(width: 24)
      Text(title)
        .font(.body)
      Spacer()
    }
    .padding(.vertical, 14)
    .padding(.horizontal, 18)
    .contentShape(Rectangle())
    .buttonStyle(.plain)
    .foregroundStyle(Palette.icon)
  }
}

// MARK: - QR-generator
private extension StartConversationView {
  var qrImage: Image {
    let data = Data(ownAddress.utf8)
    let context = CIContext()
    let filter  = CIFilter.qrCodeGenerator()
    filter.setValue(data, forKey: "InputMessage")
    filter.setValue("M", forKey: "InputCorrectionLevel")

    guard
      let outputImage = filter.outputImage,
      let cgImg       = context.createCGImage(outputImage, from: outputImage.extent)
    else {
      return Image(systemName: "xmark.circle")
    }
    return Image(decorative: cgImg, scale: 1)
  }
}

// MARK: – Preview

#Preview {
  NavigationStack {
    StartConversationView()
      .environmentObject(ToxManager.preview)
  }
}
