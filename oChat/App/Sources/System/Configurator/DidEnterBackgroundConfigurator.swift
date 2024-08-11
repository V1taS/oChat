//
//  DidEnterBackgroundConfigurator.swift
//  oChat
//
//  Created by Vitalii Sosin on 11.08.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import SKUIKit
import UIKit
import SKStyle
import SwiftUI
import ToxCore
import SKServices

struct DidEnterBackgroundConfigurator: Configurator {
  
  // MARK: - Private properties
  
  private let services: IApplicationServices
  
  // MARK: - Init
  
  init(services: IApplicationServices) {
    self.services = services
  }
  
  // MARK: - Internal func
  
  func configure() {
    keepToxCoreActive()
  }
}

// MARK: - Private

private extension DidEnterBackgroundConfigurator {
  func keepToxCoreActive() {
    ToxCore.shared.setMessageCallback { friendId, jsonString in
      DispatchQueue.main.async {
        handleMessageReceived(jsonString: jsonString, friendId: friendId)
      }
    }
  }
  
  func handleMessageReceived(jsonString: String?, friendId: Int32) {
    guard let jsonString,
          let jsonData = jsonString.data(using: .utf8),
          let messageModel = try? JSONDecoder().decode(MessengerNetworkRequestDTO.self, from: jsonData).mapToModel() else {
      return
    }
    
    Task {
      let cryptoService = services.accessAndSecurityManagementService.cryptoService
      let systemService = services.userInterfaceAndExperienceService.systemService
      let contactsDataManager = services.messengerService.contactsDataManager
      let messengeDataManager = services.messengerService.messengeDataManager
      let appSettingsDataManager = services.messengerService.appSettingsDataManager
      let p2pChatManager = services.messengerService.p2pChatManager
      let contactModels = await services.messengerService.contactsDataManager.getListContactModels()
      
      updateRedDotToTabBar(contactModels: contactModels)
      let messageText = cryptoService.decrypt(
        messageModel.messageText,
        privateKey: systemService.getDeviceIdentifier()
      ) ?? ""
      let pushNotificationToken = cryptoService.decrypt(
        messageModel.senderPushNotificationToken,
        privateKey: systemService.getDeviceIdentifier()
      )
      
      if let contact = searchContact(
        contactModels: contactModels,
        torAddress: messageModel.senderAddress
      ) {
        let updatedContact = updateExistingContact(
          contact: contact,
          messageModel: messageModel,
          pushNotificationToken: pushNotificationToken
        )
        
        let messengeModel = addMessageToContact(
          message: messageText,
          messageType: .received,
          replyMessageText: messageModel.replyMessageText,
          images: [],
          videos: [],
          recording: nil
        )
        
        await messengeDataManager.addMessenge(contact.id, messengeModel)
        await contactsDataManager.saveContact(updatedContact)
        await saveToxState(appSettingsDataManager: appSettingsDataManager, p2pChatManager: p2pChatManager)
        sendLocalNotification(contactModel: updatedContact)
      } else {
        let newContact = createNewContact(
          messageModel: messageModel,
          pushNotificationToken: pushNotificationToken,
          status: .online
        )
        await contactsDataManager.saveContact(newContact)
        sendLocalNotification(contactModel: newContact)
      }
    }
  }
  
  func updateRedDotToTabBar(contactModels: [ContactModel]) {
    let newMessages = contactModels.filter({ $0.isNewMessagesAvailable })
    let redDotToTabBarText: String? = newMessages.isEmpty ? nil : "\(newMessages.count)"
    DispatchQueue.main.async {
      guard let tabBarController = UIApplication.currentWindow?.rootViewController as? UITabBarController,
            (tabBarController.tabBar.items?.count ?? .zero) > .zero else {
        return
      }
      
      tabBarController.tabBar.items?[.zero].badgeValue = redDotToTabBarText
      tabBarController.tabBar.items?[.zero].badgeColor = SKStyleAsset.constantRuby.color
    }
  }
  
  func searchContact(contactModels: [ContactModel], torAddress: String) -> ContactModel? {
    if let contactIndex = contactModels.firstIndex(where: { $0.toxAddress == torAddress }) {
      return contactModels[contactIndex]
    }
    return nil
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
  
  func saveToxState(appSettingsDataManager: IAppSettingsDataManager, p2pChatManager: IP2PChatManager) async {
    let stateAsString = await p2pChatManager.toxStateAsString()
    await appSettingsDataManager.setToxStateAsString(stateAsString)
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
      isTyping: false,
      canSaveMedia: messageModel.canSaveMedia,
      isChatHistoryStored: messageModel.isChatHistoryStored
    )
  }
  
  func sendLocalNotification(contactModel: ContactModel) {
    DispatchQueue.main.async {
      if UIApplication.shared.applicationState == .background {
        let address: String = "\(contactModel.toxAddress?.formatString(minTextLength: 10) ?? "unknown")"
        let content = UNMutableNotificationContent()
        content.title = OChatStrings.MessengerListScreenModuleLocalization
          .LocalNotification.title
        content.body = "\(OChatStrings.MessengerListScreenModuleLocalization.LocalNotification.body) \(address)."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { _ in }
      }
    }
  }
}
