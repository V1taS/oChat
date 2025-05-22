//
//  EditAvatarView.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

struct EditAvatarView: View {

  // MARK: - Public Properties

  @EnvironmentObject var friendManager: FriendManager
  private let friendModel: FriendModel

  @State var color: Color = .blue
  @State var icon: AvatarModel.IconType = .customEmoji("?")

  // MARK: - Init

  init(friendModel: FriendModel) {
    self.friendModel = friendModel
    self.color = friendModel.avatar.color
    self.icon = friendModel.avatar.icon
  }

  // MARK: - Private States

  @Environment(\.dismiss) private var dismiss
  @FocusState private var isEmojiKeyboardFocused: Bool
  @State private var typedEmoji: String = ""

  // MARK: - View Body

  var body: some View {
    NavigationStack {
      VStack {
        Form {
          // Визуальная часть
          Section {
            ZStack {
              Circle()
                .foregroundColor(color.opacity(0.2))
                .frame(width: 100, height: 100)
                .shadow(color: color.opacity(0.6),
                        radius: 8, x: 0, y: 4)

              // Показываем либо эмодзи, либо SF Symbol
              switch icon {
              case .systemSymbol(let systemName):
                Image(systemName: systemName)
                  .resizable()
                  .scaledToFit()
                  .frame(maxHeight: 40)
                  .foregroundColor(color)
              case .customEmoji(let emoji):
                Text(emoji)
                  .foregroundColor(color)
                  .fontWeight(.bold)
                  .font(.system(size: 40))
              }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 4)
          }

          // Секция выбора цвета
          Section {
            let columns = [GridItem(.adaptive(minimum: 40), spacing: 12)]
            LazyVGrid(columns: columns, spacing: 12) {
              ForEach(availableColors, id: \.self) { color in
                ZStack {
                  Circle()
                    .foregroundColor(color)
                    .frame(width: 42, height: 42)
                    .padding(4)
                    .overlay(
                      Circle()
                        .stroke(
                          Color.gray.opacity(
                            self.color == color ? 0.8 : 0
                          ),
                          lineWidth: 2
                        )
                    )
                }
                .onTapGesture {
                  self.color = color
                }
              }
            }
            .padding(.vertical, 4)
          } header: {
            Text(localized(key: "SelectColor"))
              .padding(.leading, -16)
          }

          // Секция выбора иконки
          Section {
            let columns = [GridItem(.adaptive(minimum: 40), spacing: 12)]
            LazyVGrid(columns: columns, spacing: 12) {
              ForEach(availableIcons, id: \.self) { icon in
                switch icon {
                case let .customEmoji(defaultEmoji):
                  ZStack {
                    Circle()
                      .foregroundColor(
                        (self.icon == .customEmoji(extractEmoji()))
                        ? self.color.opacity(0.2)
                        : Color.gray.opacity(0.1)
                      )
                      .frame(width: 42, height: 42)

                    Text(currentlySelectedEmoji(defaultEmoji: defaultEmoji))
                      .foregroundColor(color)
                      .fontWeight(.bold)
                      .font(.system(size: 18))
                  }
                  .onTapGesture {
                    // Пользователь выбирает customEmoji
                    self.icon = .customEmoji(defaultEmoji)
                    typedEmoji = defaultEmoji
                    // При нажатии — фокусируемся на «скрытом» TextField для эмодзи
                    isEmojiKeyboardFocused = true
                  }

                case let .systemSymbol(sysName):
                  ZStack {
                    Circle()
                      .foregroundColor(
                        (self.icon == .systemSymbol(sysName))
                        ? color.opacity(0.2)
                        : Color.gray.opacity(0.1)
                      )
                      .frame(width: 42, height: 42)

                    Image(systemName: sysName)
                      .resizable()
                      .scaledToFit()
                      .frame(maxHeight: 15)
                      .foregroundColor(
                        (self.icon == .systemSymbol(sysName))
                        ? color
                        : .primary
                      )
                  }
                  .onTapGesture {
                    self.icon = .systemSymbol(sysName)
                  }
                }
              }
            }
            .padding(.vertical, 4)
          } header: {
            Text(localized(key: "SelectIcon"))
              .padding(.leading, -16)
          }
        }
      }
      .navigationTitle(friendModel.shortAddress)
      .navigationBarTitleDisplayMode(.large)

      // При отображении клавиатуры показываем "Готово" в нижней части
      .safeAreaInset(edge: .bottom) {
        if isEmojiKeyboardFocused {
          HStack {
            Spacer()
            Button(localized(key: "doneTitle")) {
              // Скрыть клавиатуру вручную
              isEmojiKeyboardFocused = false
            }
            .padding(.trailing)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background(.regularMaterial)
        }
      }

      // Кнопки в Toolbar
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(localized(key: "cancel")) {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(localized(key: "doneTitle")) {
            processCategory()
            dismiss()
          }
        }
      }

      // «Скрытый» TextField для ввода эмодзи
      .overlay(
        TextField("", text: $typedEmoji)
          .focused($isEmojiKeyboardFocused)
          .onChange(of: typedEmoji) { newValue, _ in
            if let last = newValue.last {
              // Если ввели эмодзи, берём последний символ
              self.icon = .customEmoji(String(last))
              isEmojiKeyboardFocused = false
              typedEmoji = ""
            }
          }
          .keyboardType(.default)
          .textInputAutocapitalization(.none)
          .frame(width: 0, height: 0)
          .opacity(0)
      )
      // По закрытию сбрасываем введённые данные
      .onDisappear {

      }
    }
  }

  // MARK: - Private Helpers

  /// Обработка сохранения новой или редактируемой категории
  private func processCategory() {
    friendManager.bindingForFriend(friendModel)?.avatar.color.wrappedValue = self.color
    friendManager.bindingForFriend(friendModel)?.avatar.icon.wrappedValue = self.icon
  }

  /// Показываем текущее эмодзи, если оно уже выбрано пользователем
  /// или дефолтное из списка
  private func currentlySelectedEmoji(defaultEmoji: String) -> String {
    let currentlySelectedEmoji: String
    switch self.icon {
    case let .customEmoji(userEmoji):
      currentlySelectedEmoji = userEmoji
    default:
      currentlySelectedEmoji = defaultEmoji
    }
    return currentlySelectedEmoji
  }

  /// Показать пользователю ошибку
  private func handleFailure(_ actionTitle: String) {
    Task {
      NotificationService.shared.showNegativeAlertWith(title: actionTitle)
    }
  }

  /// Локализация
  private func localized(key: String) -> String {
    NSLocalizedString(
      key,
      tableName: "ScreensLocalizable",
      bundle: .main,
      value: key,
      comment: ""
    )
  }

  // Простой метод, чтобы извлечь строку-эмодзи из newCategoryIcon, если это .customEmoji
  private func extractEmoji() -> String {
    switch self.icon {
    case let .customEmoji(e):
      return e
    default:
      return "🙂"
    }
  }
}

extension EditAvatarView {
  var availableColors: [Color] {
    [
      .red, .orange, .yellow, .green,
      .mint, .teal, .blue, .indigo,
      .purple, .pink, .brown, .gray,
      .black,
      .cyan,
      Color(red: 1.0, green: 0.0, blue: 1.0),
      Color(red: 0.5, green: 0.0, blue: 0.5),
      Color(red: 0.5, green: 0.0, blue: 0.0),
      Color(red: 0.0, green: 0.0, blue: 0.5),
      Color(red: 0.5, green: 0.5, blue: 0.0),
      Color(red: 1.0, green: 0.84, blue: 0.0),
      Color(red: 0.82, green: 0.41, blue: 0.12)
    ]
  }

  var availableIcons: [AvatarModel.IconType] {
    [
      // Первый элемент - «кастомная эмодзи»
      .customEmoji("🙂"),

      // Системные иконки SF Symbols
      .systemSymbol("list.bullet"),
      .systemSymbol("star.fill"),
      .systemSymbol("heart.fill"),
      .systemSymbol("flag.fill"),
      .systemSymbol("house.fill"),
      .systemSymbol("folder.fill"),
      .systemSymbol("tray.fill"),
      .systemSymbol("bell.fill"),
      .systemSymbol("cart.fill"),
      .systemSymbol("checkmark"),
      .systemSymbol("person.fill"),
      .systemSymbol("pencil"),
      .systemSymbol("envelope.fill"),
      .systemSymbol("calendar"),
      .systemSymbol("paperplane.fill"),
      .systemSymbol("clock.fill"),
      .systemSymbol("book.fill"),
      .systemSymbol("bookmark.fill"),
      .systemSymbol("graduationcap.fill"),
      .systemSymbol("gamecontroller.fill"),
      .systemSymbol("bag.fill"),
      .systemSymbol("airplane"),
      .systemSymbol("car.fill"),
      .systemSymbol("bicycle"),
      .systemSymbol("gearshape.fill"),
      .systemSymbol("bed.double.fill"),
      .systemSymbol("hammer.fill"),
      .systemSymbol("leaf.fill"),
      .systemSymbol("doc.text.fill"),
      .systemSymbol("flame.fill"),
      .systemSymbol("camera.fill"),
      .systemSymbol("music.note"),
      .systemSymbol("bubble.left.fill"),
      .systemSymbol("magnifyingglass"),
      .systemSymbol("exclamationmark.circle.fill"),
      .systemSymbol("bell.badge.fill"),
      .systemSymbol("fork.knife"),
      .systemSymbol("shippingbox.fill"),
      .systemSymbol("ticket.fill")
    ]
  }
}

// MARK: - Preview

#Preview {
  EditAvatarView(friendModel: .mockList().first!)
    .environmentObject(FriendManager.preview)
}
