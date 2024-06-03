//
//  MessengerListScreenModuleFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit

/// Cобытия которые отправляем из Factory в Presenter
protocol MessengerListScreenModuleFactoryOutput: AnyObject {
  /// Открыть экран с диалогом
  func openMessengerDialogScreen(dialogModel: MessengerDialogModel)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol MessengerListScreenModuleFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать список моделек с виджетами
  func createDialogWidgetModels() -> [WidgetCryptoView.Model]
}

/// Фабрика
final class MessengerListScreenModuleFactory {
  // MARK: - Internal properties
  private let messengerDialogModels: [MessengerDialogModel]
  weak var output: MessengerListScreenModuleFactoryOutput?

  init(messengerDialogModels: [MessengerDialogModel]) {
    self.messengerDialogModels = messengerDialogModels
  }
}

// MARK: - MessengerListScreenModuleFactoryInput

extension MessengerListScreenModuleFactory: MessengerListScreenModuleFactoryInput {
  func createHeaderTitle() -> String {
    return oChatStrings.MessengerListScreenModuleLocalization
      .State.Header.title
  }
  
  func createDialogWidgetModels() -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []

    messengerDialogModels.forEach { dialogModel in
      models.append(
        WidgetCryptoView.Model(
          leftSide: .init(
            imageModel: nil,
            itemModel: nil,
            titleModel: .init(
              text: dialogModel.recipientName,
              textStyle: .standart,
              textIsSecure: false
            ),
            titleAdditionRoundedModel: nil,
            descriptionModel: .init(
              text: dialogModel.messenges.last?.message ?? "",
              lineLimit: 2,
              textStyle: .netural,
              textIsSecure: false
            ),
            descriptionAdditionModel: nil,
            descriptionAdditionRoundedModel: nil
          ),
          rightSide: .init(
            imageModel: .chevron,
            itemModel: nil,
            titleModel: .init(
              text: "25.122023",
              textStyle: .netural,
              textIsSecure: false
            ),
            titleAdditionModel: nil,
            titleAdditionRoundedModel: nil,
            descriptionModel: nil,
            descriptionAdditionModel: nil,
            descriptionAdditionRoundedModel: nil
          ),
          isSelectable: true,
          backgroundColor: nil,
          action: { [weak self] in
            self?.output?.openMessengerDialogScreen(dialogModel: dialogModel)
          }
        )
      )
    }
    return models
  }
}

// MARK: - Private

private extension MessengerListScreenModuleFactory {
}

// MARK: - Constants

private enum Constants {}
