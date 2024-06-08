//
//  MessengerListScreenModuleFactory.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions
import SKFoundation

/// Cобытия которые отправляем из Factory в Presenter
protocol MessengerListScreenModuleFactoryOutput: AnyObject {
  /// Открыть экран с диалогом
  func openMessengerDialogScreen(dialogModel: ContactModel)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol MessengerListScreenModuleFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать список моделек с виджетами
  func createDialogWidgetModels(messengerDialogModels: [ContactModel]) -> [WidgetCryptoView.Model]
  
  /// Добавить сообщение
  func addMessageToContact(
    message: String?,
    contactModel: ContactModel,
    messageType: MessengeModel.MessageType
  ) -> ContactModel
  
  /// Удалить сообщение
  func removeMessageToContact(
    message: String?,
    contactModel: ContactModel
  ) -> ContactModel
  
  /// Найти контакт в массиве
  func searchContact(
    contactModels: [ContactModel],
    torAddress: String
  ) -> ContactModel?
}

/// Фабрика
final class MessengerListScreenModuleFactory {
  
  // MARK: - Internal properties

  weak var output: MessengerListScreenModuleFactoryOutput?
}

// MARK: - MessengerListScreenModuleFactoryInput

extension MessengerListScreenModuleFactory: MessengerListScreenModuleFactoryInput {
  func searchContact(contactModels: [ContactModel], torAddress: String) -> ContactModel? {
    if let contactIndex = contactModels.firstIndex(where: { $0.onionAddress == torAddress }) {
      return contactModels[contactIndex]
    }
    return nil
  }
  
  func addMessageToContact(
    message: String?,
    contactModel: ContactModel,
    messageType: MessengeModel.MessageType
  ) -> ContactModel {
    var updatedModel = contactModel
    if let message {
      updatedModel.messenges.append(
        .init(
          messageType: messageType,
          messageStatus: messageType == .own ? .inProgress : .delivered,
          message: message,
          file: nil
        )
      )
    }
    return updatedModel
  }
  
  func removeMessageToContact(
    message: String?,
    contactModel: ContactModel
  ) -> ContactModel {
    var updatedModel = contactModel
    var updatedMessengesModel = updatedModel.messenges
    
    if let messengeIndex = updatedMessengesModel.firstIndex(where: { $0.message == message}) {
      updatedMessengesModel.remove(at: messengeIndex)
    }
    updatedModel.messenges = updatedMessengesModel
    return updatedModel
  }
  
  func createHeaderTitle() -> String {
    return MessengerSDKStrings.MessengerListScreenModuleLocalization.stateHeaderTitle
  }
  
  func createDialogWidgetModels(messengerDialogModels: [ContactModel]) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    messengerDialogModels.forEach { dialogModel in
      let title = ((dialogModel.name ?? dialogModel.onionAddress) ?? "").formatString(minTextLength: 20)
      var dateLastMessage = ""
      
      var contactStatusStyle: WidgetCryptoView.TextStyle = .netural
      switch dialogModel.status {
      case .online:
        contactStatusStyle = .positive
      case .offline:
        contactStatusStyle = .negative
      case .inProgress:
        contactStatusStyle = .netural
      case .requested:
        contactStatusStyle = .netural
      }
      
      models.append(
        WidgetCryptoView.Model(
          leftSide: .init(
            imageModel: nil,
            itemModel: nil,
            titleModel: .init(
              text: title,
              textStyle: .standart,
              textIsSecure: false
            ),
            titleAdditionRoundedModel: .init(
              text: dialogModel.status.title,
              textStyle: contactStatusStyle
            ),
            descriptionModel: .init(
              text: dialogModel.messenges.last?.message ?? "",
              lineLimit: 2,
              textStyle: .netural
            )
          ),
          rightSide: .init(
            imageModel: .chevron,
            itemModel: nil,
            titleModel: .init(
              text: dateLastMessage,
              textStyle: .netural
            )
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

private extension MessengerListScreenModuleFactory {}

// MARK: - Constants

private enum Constants {}
