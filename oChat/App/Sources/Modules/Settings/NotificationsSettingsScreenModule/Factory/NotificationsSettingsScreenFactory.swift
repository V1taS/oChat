//
//  NotificationsSettingsScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit

/// Cобытия которые отправляем из Factory в Presenter
protocol NotificationsSettingsScreenFactoryOutput: AnyObject {
  /// Изменилось состояние уведомления
  func changeNotificationsState(_ value: Bool)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol NotificationsSettingsScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать виджет модельки для отображения
  func createWidgetModels(_ isNotifications: Bool) -> [WidgetCryptoView.Model]
}

/// Фабрика
final class NotificationsSettingsScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: NotificationsSettingsScreenFactoryOutput?
}

// MARK: - NotificationsSettingsScreenFactoryInput

extension NotificationsSettingsScreenFactory: NotificationsSettingsScreenFactoryInput {
  func createHeaderTitle() -> String {
    oChatStrings.NotificationsSettingsScreenLocalization
      .State.Header.title
  }
  
  func createWidgetModels(_ isNotifications: Bool) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    let notificationsModel = createWidgetModel(
      title: oChatStrings.NotificationsSettingsScreenLocalization
        .State.Notifications.title,
      description: oChatStrings.NotificationsSettingsScreenLocalization
        .State.Notifications.description,
      initialState: isNotifications,
      action: { [weak self] newValue in
        guard let self else {
          return
        }
        output?.changeNotificationsState(newValue)
      }
    )
    
    models = [
      notificationsModel
    ]
    return models
  }
}

// MARK: - Private

private extension NotificationsSettingsScreenFactory {
  func createWidgetModel(
    title: String,
    description: String,
    initialState: Bool,
    action: ((Bool) -> Void)?
  ) -> WidgetCryptoView.Model {
    return .init(
      leftSide: .init(
        titleModel: .init(
          text: title,
          lineLimit: 1,
          textStyle: .standart
        ),
        descriptionModel: .init(
          text: description,
          lineLimit: .max,
          textStyle: .netural
        )
      ),
      rightSide: .init(
        itemModel: .switcher(
          initNewValue: initialState,
          isEnabled: !(initialState == true),
          action: action
        )
      ),
      isSelectable: false
    )
  }
}

// MARK: - Constants

private enum Constants {}
