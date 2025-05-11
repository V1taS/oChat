//
//  PremiumView.swift
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
  static let accent    = LinearGradient(
    colors: [
      Color(red: 0/255, green: 183/255, blue: 241/255),
      Color(red: 0/255, green: 220/255, blue: 200/255)
    ],
    startPoint: .top,
    endPoint: .bottom
  )
  static let optionBG      = Color(.systemBackground)
  static let optionStroke  = Color.gray.opacity(0.28)
  static let mostPopularBG = LinearGradient(
    colors: [
      Color(red: 100/255, green: 145/255, blue: 255/255),
      Color(red: 70/255,  green: 205/255, blue: 210/255)
    ],
    startPoint: .top,
    endPoint: .bottom
  )
}

// MARK: - Премиум экран
struct PremiumView: View {

  /// `true` – показываем блок распродажи, `false` – обычные варианты подписки
  var isSale: Bool = false

  // MARK: - State
  @State private var selected: SubscriptionType = .monthly

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 32) {

          // Иконка приложения
          Image("oChatLogo") // замените на нужный ассет
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
            .frame(width: 180, height: 180)
            .padding(.top, 12)

          // Заголовок
          VStack(spacing: 8) {
            Text("Выберите иконку")
              .font(.title)
              .bold()
              .multilineTextAlignment(.center)
            Text("Измените внешний вид приложения по своему вкусу")
              .font(.subheadline)
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.center)
          }
          .padding(.horizontal)

          // Блок с ценами
          if isSale {
            saleBlock
          } else {
            subscriptionOptions
          }

          // Кнопка Restore
          Button("Восстановить") { restoreTapped() }
            .font(.callout)
            .padding(.top, 4)

          // Основная кнопка
          Button {
            purchaseTapped()
          } label: {
            Text(buttonTitle)
              .fontWeight(.semibold)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 14)
              .background(Palette.accent, in: Capsule(style: .continuous))
              .foregroundStyle(.white)
          }
          .padding(.horizontal)
          .padding(.bottom, 4)

          // Линки
          VStack(spacing: 2) {
            Button("Условия и Политика конфиденциальности") {
              openLegal()
            }
            .font(.footnote)
          }
          .padding(.bottom, 32)
        }
      }
      .background(Palette.sheetBG.ignoresSafeArea())
      .navigationTitle("Премиум")
      .navigationBarTitleDisplayMode(.inline)
    }
    .presentationDetents([.large])
    .presentationDragIndicator(.visible)
  }

  // MARK: - Sub-views

  /// Варианты подписки (год / месяц / навсегда)
  private var subscriptionOptions: some View {
    HStack(spacing: 20) {
      SubscriptionOptionCard(type: .year,   isSelected: selected == .year)   { selected = .year }
      SubscriptionOptionCard(type: .monthly,isSelected: selected == .monthly){ selected = .monthly }
      SubscriptionOptionCard(type: .lifetime,isSelected:selected == .lifetime){ selected = .lifetime }
    }
    .padding(.horizontal, 20)
  }

  /// Блок распродажи
  private var saleBlock: some View {
    VStack(spacing: 12) {
      Text("Распродажа\n(Разовая покупка)")
        .multilineTextAlignment(.center)
        .font(.title3)
        .bold()
        .foregroundStyle(Color.red)

      Text("24 ,990.00 ₸")
        .font(.title3)
        .foregroundStyle(.secondary)
        .strikethrough()

      Text("4 ,990.00 ₸")
        .font(.largeTitle)
        .bold()
    }
    .padding(.vertical, 24)
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(Palette.optionBG)
        .shadow(radius: 5, y: 2)
    )
    .padding(.horizontal, 20)
  }

  // MARK: - Helpers

  private var buttonTitle: String {
    if isSale { return "Купить за 4 ,990.00 ₸" }
    switch selected {
    case .year:     return "Подписаться за 4 ,990.00 ₸"
    case .monthly:  return "Подписаться за 499.00 ₸"
    case .lifetime: return "Купить за 24 ,990.00 ₸"
    }
  }

  private func purchaseTapped() {
    // TODO: подключите здесь логику StoreKit
  }

  private func restoreTapped() {
    // TODO: восстановление покупок
  }

  private func openLegal() {
    // TODO: открыть веб-страницу
  }

  @Environment(\.dismiss) private var dismiss
}

// MARK: - SubscriptionOptionCard
private struct SubscriptionOptionCard: View {

  let type: SubscriptionType
  let isSelected: Bool
  let tap: () -> Void

  var body: some View {
    Button(action: tap) {
      VStack(spacing: 6) {
        if type == .monthly {
          Text("Самый\nпопулярный")
            .font(.caption2)
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .padding(.top, 6)
            .frame(maxWidth: .infinity)
        }

        Text(type.title)
          .font(.largeTitle)
          .bold()

        Text(type.subtitle)
          .font(.subheadline)
          .foregroundStyle(.secondary)

        Text(type.price)
          .font(.headline)
          .padding(.bottom, 8)
      }
      .frame(width: 104)
      .background(background)
      .overlay(
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .strokeBorder(Palette.optionStroke, lineWidth: 0.5)
      )
      .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    .buttonStyle(.plain)
  }

  private var background: some View {
    Group {
      if type == .monthly {
        Palette.mostPopularBG
      } else {
        Palette.optionBG
      }
    }
  }
}

// MARK: - SubscriptionType
private enum SubscriptionType {
  case year, monthly, lifetime

  var title: String {
    switch self {
    case .year:     return "12"
    case .monthly:  return "1"
    case .lifetime: return "∞"
    }
  }

  var subtitle: String {
    switch self {
    case .year:     return "Ежегодно"
    case .monthly:  return "Ежемесячно"
    case .lifetime: return ""
    }
  }

  var price: String {
    switch self {
    case .year:     return "4 ,990.00 ₸"
    case .monthly:  return "499.00 ₸"
    case .lifetime: return "24 ,990.00 ₸"
    }
  }
}

// MARK: - Preview
#Preview {
  Group {
    PremiumView(isSale: false) // обычный режим
    PremiumView(isSale: true)  // распродажа
  }
  .environment(\.locale, .init(identifier: "ru"))
}
