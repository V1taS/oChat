//
//  CreateGroupView.swift
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
  static let accent    = Color.accentColor          // цвет кнопки «Создать»
  static let warnBG    = Color.orange.opacity(0.9)  // баннер-предупреждение
  static let icon      = Color.primary
}

// MARK: - Model-заглушка
private struct Contact: Identifiable, Hashable {
  let id: UUID = .init()
  let name: String
  let avatarText: String   // инициалы или emoji
}

// MARK: - Экран
struct CreateGroupView: View {

  // MARK: Environment
  @Environment(\.dismiss) private var dismiss

  // MARK: State
  @State private var groupName   = ""
  @State private var searchQuery = ""
  @State private var selectedIDs: Set<Contact.ID> = []

  // Временный список контактов
  @State private var contacts: [Contact] = [
    .init(name: "no1", avatarText: "NO"),
    .init(name: "😊",  avatarText: "😊")
  ]

  // MARK: - Body
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        ScrollView {
          VStack(spacing: 24) {

            groupNameField
              .padding(.horizontal)

            searchField
              .padding(.horizontal)

            contactsList
          }
          .padding(.top, 12)
          .padding(.bottom, 20)
        }

        createButton
          .padding(.horizontal, 40)
          .padding(.bottom, 12)
      }
      .background(Palette.sheetBG.ignoresSafeArea())
      .navigationTitle("Создать группу")
      .navigationBarTitleDisplayMode(.large)
    }
    .presentationDetents([.large])
    .presentationDragIndicator(.visible)
  }
}

// MARK: - Sub-views
private extension CreateGroupView {

  // Поле «Название группы»
  var groupNameField: some View {
    TextField("Введите название группы", text: $groupName)
      .textFieldStyle(.roundedBorder) // нативная закруглённая рамка
      .disableAutocorrection(true)
      .textInputAutocapitalization(.sentences)
  }

  // Поиск по контактам
  var searchField: some View {
    HStack(spacing: 8) {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(.secondary)
      TextField("Поиск контактов", text: $searchQuery)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .strokeBorder(Palette.separator, lineWidth: 0.5)
    )
  }

  // Список контактов
  var contactsList: some View {
    VStack(spacing: 0) {
      ForEach(filteredContacts) { contact in
        ContactRow(
          contact: contact,
          isSelected: selectedIDs.contains(contact.id)
        )
        .contentShape(Rectangle())
        .onTapGesture {
          toggle(contact)
        }

        if contact.id != filteredContacts.last?.id {
          divider
        }
      }
    }
    .background(.ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .strokeBorder(Palette.separator, lineWidth: 0.5)
    )
    .padding(.horizontal)
  }

  // Кнопка «Создать»
  var createButton: some View {
    Button {
      createGroup()
    } label: {
      Text("Создать")
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
    .background(
      RoundedRectangle(cornerRadius: 28, style: .continuous)
        .strokeBorder(Palette.accent, lineWidth: 1.5)
    )
    .disabled(groupName.isEmpty || selectedIDs.isEmpty)
    .opacity((groupName.isEmpty || selectedIDs.isEmpty) ? 0.4 : 1)
  }

  var divider: some View {
    Rectangle()
      .fill(Palette.separator)
      .frame(height: 1 / UIScreen.main.scale)
  }

  // Отфильтрованные контакты
  var filteredContacts: [Contact] {
    guard !searchQuery.isEmpty else { return contacts }
    return contacts.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
  }

  // Переключаем выделение
  func toggle(_ contact: Contact) {
    if selectedIDs.contains(contact.id) {
      selectedIDs.remove(contact.id)
    } else {
      selectedIDs.insert(contact.id)
    }
  }

  // Логика создания группы (заглушка)
  func createGroup() {
    // TODO: передать selectedIDs и groupName в менеджер групп
    dismiss()
  }
}

// MARK: - ContactRow
private struct ContactRow: View {
  let contact: Contact
  let isSelected: Bool

  var body: some View {
    HStack(spacing: 18) {
      ZStack {
        Circle()
          .fill(Color.orange.gradient)
          .frame(width: 48, height: 48)

        Text(contact.avatarText)
          .font(.headline)
          .foregroundStyle(.white)
      }

      Text(contact.name)
        .font(.body)

      Spacer()

      Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
        .foregroundStyle(Palette.icon)
        .font(.title3)
        .padding(.trailing, 4)
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 18)
    .background(isSelected ? Color.accentColor.opacity(0.08) : .clear)
  }
}

// MARK: - Preview
#Preview {
  CreateGroupView()
}
