//
//  StartConversationView.swift
//  oChat
//
//  Updated on 10.05.2025
//  • Заголовок и кнопка «Закрыть» перенесены в Navigation-bar.
//  • Отступы и фон (#E7F6F9) сохранены.
//  • QR-код теперь содержит логотип в центре.
//  • Large title убран, всё скроллится с обычным навбаром.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Palette
private enum Palette {
  static let sheetBG   = Color(.systemGroupedBackground)
  static let separator = Color.gray.opacity(0.22)
  static let icon      = Color.primary
}

// MARK: - Экран
struct StartConversationView: View {
  // MARK: Public API
  let onNewMessage: () -> Void = {}
  let onCreateGroup: () -> Void = {}
  let onInviteFriend: () -> Void = {}

  // MARK: Environment
  @Environment(\.dismiss) private var dismiss
  @StateObject private var tox = ToxManager.shared
  @State private var ownAddress = ""

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
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .font(.headline)
          }
          .accessibilityLabel("Закрыть")
        }
      }
      .task {
        ownAddress = await tox.getOwnAddress()
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
      ActionRow(icon: "bubble.left.and.bubble.right",
                title: "Новое сообщение",
                action: onNewMessage)
      divider
      ActionRow(icon: "person.3",
                title: "Создать группу",
                action: onCreateGroup)
      divider
      ActionRow(icon: "person.badge.plus",
                title: "Пригласить друга",
                action: onInviteFriend)
    }
    .background(.ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .strokeBorder(Palette.separator, lineWidth: 0.5)
    )
    .padding(.horizontal)
  }

  // ID + QR-код
  var idAndQRBlock: some View {
    VStack(alignment: .center, spacing: 14) {
      Text("ID вашего аккаунта")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)

      Text("Друзья могут отправить вам сообщение, отсканировав ваш QR-код.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)

      // QR-код + логотип
      ZStack {
        qrImage
          .interpolation(.none)
          .resizable()
          .scaledToFit()

        Image("oChatLogo")          // ⬅️ логотип в центре
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
  let action: () -> Void

  var body: some View {
    Button(action: action) {
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
    }
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
    filter.setValue("M",   forKey: "InputCorrectionLevel")

    guard
      let outputImage = filter.outputImage,
      let cgImg       = context.createCGImage(outputImage, from: outputImage.extent)
    else {
      return Image(systemName: "xmark.circle")
    }
    return Image(decorative: cgImg, scale: 1)
  }
}

// MARK: - Preview
#Preview {
  StartConversationView()
}
