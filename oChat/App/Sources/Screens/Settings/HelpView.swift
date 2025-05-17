//
//  HelpView.swift
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
  static let accent    = Color(red: 0/255,   green: 183/255,  blue: 241/255)
}

// MARK: - View
struct HelpView: View {

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {

          // MARK: Сообщить об ошибке
          ErrorReportCard(
            onExportLogs: exportLogs
          )

          // MARK: Ссылки-помощники
          LinkRow("Помогите нам перевести Session") {
            open(url: "https://translate.example.com")
          }

          LinkRow("Мы будем рады вашим отзывам") {
            open(url: "https://feedback.example.com")
          }

          LinkRow("FAQ") {
            open(url: "https://faq.example.com")
          }

          LinkRow("Поддержка") {
            open(url: "https://support.example.com")
          }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
      }
      .background(Color(.systemGroupedBackground).ignoresSafeArea())
      .navigationTitle("Помощь")
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

  // MARK: – Actions
  private func exportLogs() {
    // Заглушка: здесь вставьте экспорт логов и шаринг/сохранение
    print("Export logs tapped")
  }

  private func open(url: String) {
    guard let url = URL(string: url) else { return }
    UIApplication.shared.open(url)
  }
}

// MARK: - ErrorReportCard
private struct ErrorReportCard: View {

  var onExportLogs: () -> Void

  var body: some View {
    HStack(alignment: .top, spacing: 18) {
      VStack(alignment: .leading, spacing: 4) {
        Text("Сообщить\nоб ошибке")
          .font(.headline)
          .fixedSize(horizontal: false, vertical: true)

        Text("Экспортируйте свои логи, затем загрузите файл через Help Desk.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)

      Button(action: onExportLogs) {
        Text("Экспортировать логи")
          .font(.body.weight(.semibold))
          .padding(.horizontal, 18)
          .padding(.vertical, 10)
          .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .fill(Color(.systemGray6))
          )
      }
      .buttonStyle(.plain)
    }
    .padding(18)
    .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - LinkRow
private struct LinkRow: View {
  let title: String
  var action: () -> Void

  init(_ title: String, action: @escaping () -> Void) {
    self.title  = title
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      HStack {
        Text(title)
          .font(.body)
          .frame(maxWidth: .infinity, alignment: .leading)

        Image(systemName: "arrow.up.right.square")
          .font(.body.weight(.semibold))
          .foregroundStyle(.blue)
      }
      .padding(.vertical, 18)
      .padding(.horizontal, 18)
      .roundedEdge(
        backgroundColor: .clear,
        boarderColor: .clear,
        paddingHorizontal: .zero,
        paddingVertical: 4,
        cornerRadius: 16,
        tintOpacity: 0.1
      )
    }
    .buttonStyle(.plain)
    .overlay(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .stroke(Color.separator, lineWidth: 0.5)
    )
  }
}

// MARK: - Preview
#Preview {
  HelpView()
    .environment(\.locale, .init(identifier: "ru"))
}
