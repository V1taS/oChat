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
  func openMessengerDialogScreen(
    dialogModel: ContactModel
  ) async
}

/// Cобытия которые отправляем от Presenter к Factory
protocol MessengerListScreenModuleFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  
  /// Создать список моделек с виджетами
  func createDialogWidgetModels(
    messengerDialogModels: [ContactModel],
    lastMessageDictionary: [String: String]
  ) -> [WidgetCryptoView.Model]
  
  /// Добавить сообщение
  func addMessageToContact(
    message: String,
    messageType: MessengeModel.MessageType,
    replyMessageText: String?,
    images: [MessengeImageModel],
    videos: [MessengeVideoModel],
    recording: MessengeRecordingModel?
  ) -> MessengeModel
  
  /// Найти контакт в массиве
  func searchContact(
    contactModels: [ContactModel],
    torAddress: String
  ) -> ContactModel?
  
  /// Создать новый контакт
  func createNewContact(
    messageModel: MessengerNetworkRequestModel,
    pushNotificationToken: String?,
    status: ContactModel.Status
  ) -> ContactModel
  
  /// Обновить существующий контакт
  func updateExistingContact(
    contact: ContactModel,
    messageModel: MessengerNetworkRequestModel,
    pushNotificationToken: String?
  ) -> ContactModel
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
    message: String,
    messageType: MessengeModel.MessageType,
    replyMessageText: String?,
    images: [MessengeImageModel],
    videos: [MessengeVideoModel],
    recording: MessengeRecordingModel?
  ) -> MessengeModel {
    .init(
      messageType: messageType,
      messageStatus: messageType == .own ? .sending : .sent,
      message: message,
      replyMessageText: replyMessageText,
      images: images,
      videos: videos,
      recording: recording
    )
  }
  
  func createHeaderTitle() -> String {
    OChatStrings.MessengerListScreenModuleLocalization
      .State.Header.title
  }
  
  func createDialogWidgetModels(
    messengerDialogModels: [ContactModel],
    lastMessageDictionary: [String: String]
  ) -> [WidgetCryptoView.Model] {
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
              text: lastMessageDictionary[dialogModel.id] ?? "",
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
            Task { [weak self] in
              guard let self else { return }
              await output?.openMessengerDialogScreen(dialogModel: dialogModel)
            }
          }
        )
      )
    }
    return models
  }
  
  func createNewContact(
    messageModel: MessengerNetworkRequestModel,
    pushNotificationToken: String?,
    status: ContactModel.Status
  ) -> ContactModel {
    return ContactModel(
      name: nil,
      toxAddress: messageModel.senderAddress,
      meshAddress: messageModel.senderLocalMeshAddress,
      status: status,
      encryptionPublicKey: messageModel.senderPublicKey,
      toxPublicKey: messageModel.senderToxPublicKey,
      pushNotificationToken: pushNotificationToken,
      isNewMessagesAvailable: true,
      isTyping: true,
      canSaveMedia: messageModel.canSaveMedia,
      isChatHistoryStored: messageModel.isChatHistoryStored
    )
  }
  
  func updateExistingContact(
    contact: ContactModel,
    messageModel: MessengerNetworkRequestModel,
    pushNotificationToken: String?
  ) -> ContactModel {
    var updatedContact = contact
    updatedContact.status = .online
    if let senderPushNotificationToken = pushNotificationToken {
      updatedContact.pushNotificationToken = senderPushNotificationToken
    }
    updatedContact.toxAddress = messageModel.senderAddress
    updatedContact.meshAddress = messageModel.senderLocalMeshAddress
    updatedContact.isNewMessagesAvailable = true
    updatedContact.encryptionPublicKey = messageModel.senderPublicKey
    updatedContact.toxPublicKey = messageModel.senderToxPublicKey
    updatedContact.canSaveMedia = messageModel.canSaveMedia
    updatedContact.isChatHistoryStored = messageModel.isChatHistoryStored
    return updatedContact
  }
}

// MARK: - Private

private extension MessengerListScreenModuleFactory {}

// MARK: - Constants

private enum Constants {}
