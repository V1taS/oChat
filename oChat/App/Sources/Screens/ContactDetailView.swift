//
//  ContactDetailView.swift
//  oChat
//
//  Created by Vitalii Sosin on 11.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import SwiftUI

// MARK: - Palette
private enum Palette {
  static let sheetBG = Color(.systemGroupedBackground)
  static let separator = Color.gray.opacity(0.22)
  static let accentBG  = Color(uiColor: .secondarySystemBackground)
  static let icon = Color.primary
}

// MARK: - Экран
struct ContactDetailView: View {

  @EnvironmentObject private var friendManager: FriendManager

  let friendModel: FriendModel

  // MARK: State
  @State private var selectedTab: Tab = .media
  @State private var presentEditAvatarView = false

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {

        // MARK: Аватар + имя + статус
        VStack(spacing: 8) {
          TapGestureView(
            style: .flash,
            touchesEnded: {
              presentEditAvatarView = true
            }
          ) {
            avatarView
          }

          Text(friendModel.shortAddress)
            .font(.title2.weight(.semibold))
        }
        .padding(.top, 12)

        // MARK: Action-кнопки
        actionButtons

        // MARK: Информация (телефон, username)
        infoBlock

        // MARK: Tabs + контент
        VStack(spacing: 14) {
          tabBar
        }
      }
      .padding(.horizontal)
      .padding(.bottom, 20)
    }
    .background(Palette.sheetBG.ignoresSafeArea())
    .navigationTitle("")
    .navigationBarTitleDisplayMode(.inline)
    .presentationDetents([.large])
    .presentationDragIndicator(.visible)
    .sheet(isPresented: $presentEditAvatarView) {
      EditAvatarView(friendModel: friendModel)
    }
  }
}

extension ContactDetailView {
  var avatarView: some View {
    ZStack {
      // Кружок с цветом + иконкой
      Circle()
        .foregroundColor(friendModel.avatar.color.opacity(0.2))

      switch friendModel.avatar.icon {
      case let .systemSymbol(systemName):
        Image(systemName: systemName)
          .resizable()
          .scaledToFit()
          .frame(maxHeight: 40)
          .foregroundColor(friendModel.avatar.color)
      case let .customEmoji(emoji):
        Text(emoji)
          .fontWeight(.bold)
          .font(.system(size: 40))
          .foregroundColor(friendModel.avatar.color)
      }

      Circle().fill(friendModel.connectionState == .online ? .green : .gray)
        .frame(width: 14, height: 14)
        .offset(x: -10, y: -5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
    .frame(width: 100, height: 100)
  }
}

// MARK: - Sub-components
private extension ContactDetailView {

  // five square buttons
  var actionButtons: some View {
    let buttons: [(String, String)] = [
      ("phone", "звонок"),
      ("video", "видео"),
      ("bell.slash", "звук"),
      ("magnifyingglass", "поиск"),
      ("ellipsis", "ещё")
    ]

    return HStack(spacing: 18) {
      ForEach(buttons, id: \.0) {
        icon,
        title in
        VStack(spacing: 6) {
          Image(systemName: icon)
            .font(.title3)
            .frame(width: 56, height: 56)
            .roundedEdge(
              backgroundColor: .gray,
              boarderColor: .clear,
              paddingHorizontal: 0,
              paddingVertical: 0,
              cornerRadius: 16,
              tintOpacity: 0.1
            )

          Text(title)
            .font(.caption)
        }
        .foregroundStyle(Palette.icon)
        .onTapGesture {
         // TODO: -
        }
      }
    }
  }
  //  let chatRules: ChatRules
  // phone + username + QR
  var infoBlock: some View {
    VStack(spacing: 8) {
      Group {
        if let friendBinding = friendManager.bindingForFriend(friendModel) {
          HStack {
            Text("Авто-удаление сообщений")
              .font(.footnote)
              .foregroundStyle(.primary)
            Spacer()
          }
          Picker("", selection: friendBinding.chatRules.autoDeletion) {
            ForEach(AutoDeletionPeriod.allCases, id: \.self) { period in
              Text(period.title).tag(period)
            }
          }
          .pickerStyle(.segmented)

          divider
        }
      }

      Group {
        if let friendBinding = friendManager.bindingForFriend(friendModel) {
          HStack(alignment: .center) {
            Text("Разрешить сохранение медиа")
              .font(.footnote)
              .foregroundStyle(.primary)

            Spacer()

            Toggle("", isOn: friendBinding.chatRules.isMediaSavingAllowed)
              .toggleStyle(SwitchToggleStyle())
              .fixedSize()
          }

          divider
        }
      }

      Group {
        if let friendBinding = friendManager.bindingForFriend(friendModel) {
          HStack(alignment: .center) {
            Text("Разрешить копировать текст сообщений")
              .font(.footnote)
              .foregroundStyle(.primary)

            Spacer()

            Toggle("", isOn: friendBinding.chatRules.isTextCopyAllowed)
              .toggleStyle(SwitchToggleStyle())
              .fixedSize()
          }

          divider
        }
      }

      Group {
        if let friendBinding = friendManager.bindingForFriend(friendModel) {
          HStack(alignment: .center) {
            Text("Разрешить скрывать реальный голос при звонках и аудио-сообщениях")
              .font(.footnote)
              .foregroundStyle(.primary)

            Spacer()

            Toggle("", isOn: friendBinding.chatRules.isVoiceMaskingEnabled)
              .toggleStyle(SwitchToggleStyle())
              .fixedSize()
          }

          divider
        }
      }

      Group {
        if let friendBinding = friendManager.bindingForFriend(friendModel) {
          HStack(alignment: .center) {
            Text("Разрешить отображать индикатор набора текста")
              .font(.footnote)
              .foregroundStyle(.primary)

            Spacer()

            Toggle("", isOn: friendBinding.chatRules.isTypingIndicatorEnabled)
              .toggleStyle(SwitchToggleStyle())
              .fixedSize()
          }

          divider
        }
      }

      Group {
        if let friendBinding = friendManager.bindingForFriend(friendModel) {
          HStack(alignment: .center) {
            Text("Разрешить аудио-звонки от контакта")
              .font(.footnote)
              .foregroundStyle(.primary)

            Spacer()

            Toggle("", isOn: friendBinding.chatRules.isAudioCallAllowed)
              .toggleStyle(SwitchToggleStyle())
              .fixedSize()
          }

          divider
        }
      }

      Group {
        if let friendBinding = friendManager.bindingForFriend(friendModel) {
          HStack(alignment: .center) {
            Text("Разрешить видео-звонки от контакта")
              .font(.footnote)
              .foregroundStyle(.primary)

            Spacer()

            Toggle("", isOn: friendBinding.chatRules.isVideoCallAllowed)
              .toggleStyle(SwitchToggleStyle())
              .fixedSize()
          }

          divider
        }
      }

      Group {
        if let friendBinding = friendManager.bindingForFriend(friendModel) {
          HStack(alignment: .center) {
            Text("Разрешить скриншоты экрана в этом чате")
              .font(.footnote)
              .foregroundStyle(.primary)

            Spacer()

            Toggle("", isOn: friendBinding.chatRules.areScreenshotsAllowed)
              .toggleStyle(SwitchToggleStyle())
              .fixedSize()
          }

          divider
        }
      }

      Group {
        if let friendBinding = friendManager.bindingForFriend(friendModel) {
          HStack(alignment: .center) {
            Text("Разрешить отправлять подтверждения о прочтении сообщений")
              .font(.footnote)
              .foregroundStyle(.primary)

            Spacer()

            Toggle("", isOn: friendBinding.chatRules.areReadReceiptsEnabled)
              .toggleStyle(SwitchToggleStyle())
              .fixedSize()
          }

          divider
        }
      }
    }
    .roundedEdge(
      backgroundColor: .gray,
      boarderColor: .clear,
      paddingHorizontal: 16,
      paddingVertical: 8,
      cornerRadius: 16,
      tintOpacity: 0.1
    )
  }

  var divider: some View {
    Rectangle()
      .fill(Palette.separator)
      .frame(height: 1 / UIScreen.main.scale)
  }

  // MARK: Tabs
  enum Tab: String, CaseIterable {
    case media = "Медиа"
    case files = "Файлы"
    case music = "Музыка"
    case voice = "Голосовые"
    case links = "Ссылки"
    case gif = "GIF"
  }

  var tabBar: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(Tab.allCases, id: \.self) { tab in
          Button {
            selectedTab = tab
          } label: {
            Text(tab.rawValue)
              .font(.subheadline.weight(.semibold))
              .roundedEdge(
                backgroundColor: selectedTab == tab ? .blue : .gray,
                boarderColor: .clear,
                paddingHorizontal: 12,
                paddingVertical: 4,
                cornerRadius: 12,
                tintOpacity: 0.1
              )
          }
          .foregroundStyle(.primary)
        }
      }
      .padding(.horizontal, 4)
    }
  }
}

// MARK: – Preview

#Preview {
  NavigationStack {
    ContactDetailView(friendModel: FriendModel.mockList()[1])
      .environmentObject(FriendManager.preview)
  }
}
