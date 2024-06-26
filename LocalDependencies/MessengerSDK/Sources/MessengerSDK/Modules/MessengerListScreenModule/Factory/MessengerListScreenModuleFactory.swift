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
import SKStyle

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
    id: String,
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
    if let contactIndex = contactModels.firstIndex(where: { $0.toxAddress == torAddress }) {
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
          messageStatus: messageType == .own ? .sending : .sent,
          message: message,
          file: nil
        )
      )
    }
    return updatedModel
  }
  
  func removeMessageToContact(
    id: String,
    contactModel: ContactModel
  ) -> ContactModel {
    var updatedModel = contactModel
    var updatedMessengesModel = updatedModel.messenges
    
    if let messengeIndex = updatedMessengesModel.firstIndex(where: { $0.id == id}) {
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
      let title = ((dialogModel.name ?? dialogModel.toxAddress) ?? "").formatString(minTextLength: 10)
      
      var contactStatusStyle: WidgetCryptoView.TextStyle = .netural
      switch dialogModel.status {
      case .online:
        contactStatusStyle = .positive
      case .offline:
        contactStatusStyle = .negative
      case .requestChat:
        contactStatusStyle = .netural
      case .initialChat:
        contactStatusStyle = .netural
      }
      
      var itemModel: WidgetCryptoView.ItemModel?
      if dialogModel.isNewMessagesAvailable {
        itemModel = .custom(
          item: AnyView(
          Circle()
            .foregroundColor(SKStyleAsset.constantRuby.swiftUIColor)
          ),
          size: .custom(width: .s2, height: .s2),
          isHitTesting: false
        )
      }
      
      if dialogModel.isTyping {
        itemModel = .custom(
          item: AnyView(
            TypingIndicatorView()
          ),
          size: .custom(width: .s8, height: .s4),
          isHitTesting: false
        )
      }
      
      models.append(
        WidgetCryptoView.Model(
          leftSide: .init(
            imageModel: nil,
            itemModel: itemModel,
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
              lineLimit: 1,
              textStyle: .netural
            )
          ),
          rightSide: .init(
            imageModel: .chevron,
            itemModel: nil,
            titleModel: nil
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
