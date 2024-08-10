//
//  MessengerListScreenModulePresenter+IncomingDataManager.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.08.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions
import SKFoundation
import UIKit
import SKManagers

// MARK: - IncomingDataManager

extension MessengerListScreenModulePresenter {
  func incomingDataManagerSetup() {
    incomingDataManager.onAppDidBecomeActive = { [weak self] in
      self?.handleAppDidBecomeActive()
    }
    
    incomingDataManager.onMyOnlineStatusUpdate = { [weak self] status in
      self?.handleMyOnlineStatusUpdate(status)
    }
    
    incomingDataManager.onMessageReceived = { [weak self] messageModel, toxFriendId in
      self?.handleMessageReceived(messageModel, toxFriendId)
    }
    
    incomingDataManager.onRequestChat = { [weak self] messageModel, toxPublicKey in
      self?.handleRequestChat(messageModel, toxPublicKey)
    }
    
    incomingDataManager.onFriendOnlineStatusUpdate = { [weak self] toxPublicKey, status in
      self?.handleFriendOnlineStatusUpdate(toxPublicKey, status)
    }
    
    incomingDataManager.onIsTypingFriendUpdate = { [weak self] toxPublicKey, isTyping in
      self?.handleIsTypingFriendUpdate(toxPublicKey, isTyping)
    }
    
    incomingDataManager.onFriendReadReceipt = { [weak self] toxPublicKey, messageId in
      self?.handleFriendReadReceipt(toxPublicKey, messageId)
    }
    
    incomingDataManager.onFileReceive = { [weak self] publicToxKey, filePath, progress in
      self?.handleFileReceive(publicToxKey, filePath, progress)
    }
    
    incomingDataManager.onFileSender = { [weak self] toxPublicKey, progress, messageID in
      self?.handleFileSender(toxPublicKey, progress, messageID)
    }
    
    incomingDataManager.onFileErrorSender = { [weak self] toxPublicKey, messageID in
      self?.handleFileErrorSender(toxPublicKey, messageID)
    }
    
    incomingDataManager.onScreenshotTaken = { [weak self] in
      self?.handleScreenshotTaken()
    }
  }
}

// MARK: - Handle IncomingDataManager

extension MessengerListScreenModulePresenter {
  func handleAppDidBecomeActive() {
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
      guard let self else { return }
      
      Task { [weak self] in
        guard let self else { return }
        if let deepLinkAdress = await interactor.getDeepLinkAdress() {
          moduleOutput?.openNewMessengeScreen(contactAdress: deepLinkAdress)
          interactor.deleteDeepLinkURL()
        }
        
        let appSettingsModel = await interactor.getAppSettingsModel()
        await MainActor.run { [weak self] in
          guard let self else { return }
          centerBarButtonView?.iconLeftView.image = appSettingsModel.myStatus.imageStatus
          centerBarButtonView?.labelView.text = appSettingsModel.myStatus.title
          rightBarWriteButton?.isEnabled = appSettingsModel.myStatus == .online
        }
      }
    }
    
    Task { [weak self] in
      guard let self else { return }
      await interactor.setSelfStatus(isOnline: true)
      await interactor.clearAllMessengeTempID()
      await interactor.passcodeNotSetInSystemIOSheck()
      
      if await interactor.getPushNotificationToken() == nil {
        await UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }
  
  func handleMyOnlineStatusUpdate(_ status: AppSettingsModel.Status) {
    Task { @MainActor [weak self] in
      guard let self else { return }
      centerBarButtonView?.iconLeftView.image = status.imageStatus
      centerBarButtonView?.labelView.text = status.title
      rightBarWriteButton?.isEnabled = status == .online
      await moduleOutput?.updateMyStatus(status)
    }
  }
  
  func handleMessageReceived(_ messageModel: MessengerNetworkRequestModel, _ toxFriendId: Int32) {
    Task { [weak self] in
      guard let self else { return }
      
      let contactModels = await interactor.getContactModels()
      updateRedDotToTabBar(contactModels: contactModels)
      let messageText = await interactor.decrypt(messageModel.messageText) ?? ""
      let pushNotificationToken = await interactor.decrypt(messageModel.senderPushNotificationToken)
      
      if let contact = factory.searchContact(
        contactModels: contactModels,
        torAddress: messageModel.senderAddress
      ) {
        let updatedContact = factory.updateExistingContact(
          contact: contact,
          messageModel: messageModel,
          pushNotificationToken: pushNotificationToken
        )
        
        let messengeModel = factory.addMessageToContact(
          message: messageText,
          messageType: .received,
          replyMessageText: messageModel.replyMessageText,
          images: [],
          videos: [],
          recording: nil
        )
        
        await interactor.addMessenge(contact.id, messengeModel)
        await interactor.saveContactModel(updatedContact)
        await updateListContacts()
        moduleOutput?.dataModelHasBeenUpdated()
        await impactFeedback.impactOccurred()
        sendLocalNotificationIfNeeded(contactModel: updatedContact)
        messengeDictionaryModels = await interactor.getDictionaryMessengeModels()
      } else {
        let newContact = factory.createNewContact(
          messageModel: messageModel,
          pushNotificationToken: pushNotificationToken,
          status: .online
        )
        await interactor.saveContactModel(newContact)
        await updateListContacts()
        moduleOutput?.dataModelHasBeenUpdated()
        await impactFeedback.impactOccurred()
        sendLocalNotificationIfNeeded(contactModel: newContact)
        messengeDictionaryModels = await interactor.getDictionaryMessengeModels()
      }
    }
  }
  
  func handleRequestChat(_ messageModel: MessengerNetworkRequestModel, _ toxPublicKey: String) {
    Task { [weak self] in
      guard let self else { return }
      
      let contactModels = await interactor.getContactModels()
      guard !contactModels.contains(where: {
        $0.toxAddress == messageModel.senderAddress
      }) else {
        return
      }
      
      let pushNotificationToken = await interactor.decrypt(messageModel.senderPushNotificationToken)
      updateRedDotToTabBar(contactModels: contactModels)
      
      let newContact = factory.createNewContact(
        messageModel: messageModel,
        pushNotificationToken: pushNotificationToken,
        status: .requestChat
      )
      await interactor.saveContactModel(newContact)
      await updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
      await impactFeedback.impactOccurred()
    }
  }
  
  func handleFriendOnlineStatusUpdate(_ toxPublicKey: String, _ status: ContactModel.Status) {
    Task { [weak self] in
      guard let self else { return }
      let contactModel = await interactor.getContactModelsFrom(toxPublicKey: toxPublicKey)
      guard let contactModel else { return }
      
      var updatedContactModel = contactModel
      if status == .offline {
        updatedContactModel.isTyping = false
      }
      
      await interactor.saveContactModel(updatedContactModel)
      await interactor.setStatus(updatedContactModel, status)
      await updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
    }
  }
  
  func handleIsTypingFriendUpdate(_ toxPublicKey: String, _ isTyping: Bool) {
    Task { [weak self] in
      guard let self else { return }
      
      let contactModel = await interactor.getContactModelsFrom(toxPublicKey: toxPublicKey)
      guard let contactModel else { return }
      var updatedContactModel = contactModel
      updatedContactModel.isTyping = isTyping
      updatedContactModel.status = .online
      await interactor.saveContactModel(updatedContactModel)
      await updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
    }
  }
  
  func handleFriendReadReceipt(_ toxPublicKey: String, _ messageId: UInt32) {
    Task { [weak self] in
      guard let self else { return }
      
      let contactModel = await interactor.getContactModelsFrom(toxPublicKey: toxPublicKey)
      guard let contactModel else { return }
      var updatedContactModel = contactModel
      let messenges = await interactor.getMessengeModelsFor(contactModel.id)
      updatedContactModel.status = .online
      
      if let messengesIndex = messenges.firstIndex(where: { $0.tempMessageID == messageId }) {
        var updatedMessenges = messenges[messengesIndex]
        updatedMessenges.messageStatus = .sent
        updatedMessenges.tempMessageID = nil
        await interactor.updateMessenge(contactModel, updatedMessenges)
      }
      
      await interactor.saveContactModel(updatedContactModel)
      await updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
    }
  }
  
  func handleFileReceive(_ publicToxKey: String, _ filePath: URL, _ progress: Double) {
    Task { [weak self] in
      guard let self else { return }
      
      moduleOutput?.handleFileReceive(progress: Int(progress), publicToxKey: publicToxKey)
      if progress < 100 { return }
      
      let contactModels = await interactor.getContactModels()
      
      let passwordEncodedString = interactor.getFileNameWithoutExtension(from: filePath)
      guard let decodedPasswordEncrypt = passwordEncodedString.removingPercentEncoding else {
        return
      }
      
      let password = await interactor.decrypt(decodedPasswordEncrypt)
      guard let password, let receiveAndUnzipFile = try? await interactor.receiveAndUnzipFile(
        zipFileURL: filePath,
        password: password
      ) else {
        return
      }
      let (messageModel, recordingDTO, files) = receiveAndUnzipFile
      
      updateRedDotToTabBar(contactModels: contactModels)
      let messageText = await interactor.decrypt(messageModel.messageText) ?? ""
      let pushNotificationToken = await interactor.decrypt(messageModel.senderPushNotificationToken)
      var images: [MessengeImageModel] = []
      var videos: [MessengeVideoModel] = []
      
      for fileTempURL in files {
        if fileTempURL.isImageFile() {
          let imageFile = interactor.readObjectWith(fileURL: fileTempURL) ?? Data()
          let fileExtension = fileTempURL.pathExtension
          let thumbnailData = interactor.resizeThumbnailImageWithFrame(data: imageFile) ?? Data()
          let thumbnailURL = interactor.saveObjectWith(
            fileName: UUID().uuidString,
            fileExtension: fileExtension,
            data: thumbnailData
          )
          
          guard let thumbnailURL,
                let fullImage = interactor.saveObjectWith(tempURL: fileTempURL),
                let thumbnailName = interactor.getFileName(from: thumbnailURL),
                let fullImageName = interactor.getFileName(from: fullImage) else {
            continue
          }
          
          images.append(
            .init(
              id: UUID().uuidString,
              thumbnailName: thumbnailName,
              fullName: fullImageName
            )
          )
          continue
        }
        
        if fileTempURL.isVideoFile() {
          guard let videoFileURL = interactor.saveObjectWith(tempURL: fileTempURL),
                let videoFileName = interactor.getFileName(from: videoFileURL),
                let firstFrameData = interactor.getFirstFrame(from: videoFileURL),
                let thumbnailResizeData = interactor.resizeThumbnailImageWithFrame(data: firstFrameData),
                let thumbnailURL = interactor.saveObjectWith(
                  fileName: UUID().uuidString,
                  fileExtension: "jpg",
                  data: thumbnailResizeData
                ),
                let thumbnailName = interactor.getFileName(from: thumbnailURL) else {
            continue
          }
          
          videos.append(
            .init(
              id: UUID().uuidString,
              thumbnailName: thumbnailName,
              fullName: videoFileName
            )
          )
          continue
        }
      }
      
      var recordingModel: MessengeRecordingModel?
      
      if let recordingDTO,
         let recordingURL = interactor.saveObjectWith(
          fileName: UUID().uuidString,
          fileExtension: "aac",
          data: recordingDTO.data
         ),
         let recordingName = interactor.getFileName(from: recordingURL) {
        recordingModel = .init(
          duration: recordingDTO.duration,
          waveformSamples: recordingDTO.waveformSamples,
          name: recordingName
        )
      }
      
      if let contact = factory.searchContact(
        contactModels: contactModels,
        torAddress: messageModel.senderAddress
      ) {
        let updatedContact = factory.updateExistingContact(
          contact: contact,
          messageModel: messageModel,
          pushNotificationToken: pushNotificationToken
        )
        let messengeModel = factory.addMessageToContact(
          message: messageText,
          messageType: .received,
          replyMessageText: messageModel.replyMessageText,
          images: images,
          videos: videos,
          recording: recordingModel
        )
        
        await interactor.addMessenge(contact.id, messengeModel)
        await interactor.saveContactModel(updatedContact)
        await updateListContacts()
        moduleOutput?.dataModelHasBeenUpdated()
        interactor.clearTemporaryDirectory()
        await impactFeedback.impactOccurred()
        sendLocalNotificationIfNeeded(contactModel: updatedContact)
        messengeDictionaryModels = await interactor.getDictionaryMessengeModels()
      } else {
        let newContact = factory.createNewContact(
          messageModel: messageModel,
          pushNotificationToken: pushNotificationToken,
          status: .online
        )
        await interactor.saveContactModel(newContact)
        await updateListContacts()
        moduleOutput?.dataModelHasBeenUpdated()
        interactor.clearTemporaryDirectory()
        await impactFeedback.impactOccurred()
        sendLocalNotificationIfNeeded(contactModel: newContact)
      }
    }
  }
  
  func handleFileSender(_ toxPublicKey: String, _ progress: Double, _ messageID: String) {
    Task { [weak self] in
      guard let self else { return }
      
      moduleOutput?.handleFileSender(progress: Int(progress), publicToxKey: toxPublicKey)
      if progress < 100 { return }
      
      let contactModel = await interactor.getContactModelsFrom(toxPublicKey: toxPublicKey)
      guard let contactModel else { return }
      var updatedContactModel = contactModel
      let messenges = await interactor.getMessengeModelsFor(contactModel.id)
      updatedContactModel.status = .online
      
      if let messengesIndex = messenges.firstIndex(where: { $0.id == messageID }) {
        var updatedMessenges = messenges[messengesIndex]
        updatedMessenges.messageStatus = .sent
        await interactor.updateMessenge(contactModel, updatedMessenges)
        messengeDictionaryModels = await interactor.getDictionaryMessengeModels()
      }
      
      await interactor.saveContactModel(updatedContactModel)
      await updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
    }
  }
  
  func handleFileErrorSender(_ toxPublicKey: String, _ messageID: String) {
    Task { [weak self] in
      guard let self else { return }
      let contactModel = await interactor.getContactModelsFrom(toxPublicKey: toxPublicKey)
      guard let contactModel else { return }
      var updatedContactModel = contactModel
      let messenges = await interactor.getMessengeModelsFor(contactModel.id)
      updatedContactModel.status = .online
      
      if let messengesIndex = messenges.firstIndex(where: { $0.id == messageID }) {
        var updatedMessenges = messenges[messengesIndex]
        updatedMessenges.messageStatus = .failed
        await interactor.updateMessenge(contactModel, updatedMessenges)
        messengeDictionaryModels = await interactor.getDictionaryMessengeModels()
      }
      
      await interactor.saveContactModel(updatedContactModel)
      await updateListContacts()
      moduleOutput?.dataModelHasBeenUpdated()
    }
  }
  
  func handleScreenshotTaken() {
    interactor.showNotification(
      .negative(
        title: OChatStrings.MessengerListScreenModuleLocalization
          .BanScreenshot.description
      )
    )
  }
}

// MARK: - Private

private extension MessengerListScreenModulePresenter {
  func sendLocalNotificationIfNeeded(contactModel: ContactModel) {
    // Проверка, находится ли приложение в фоне
    DispatchQueue.main.async { [weak self] in
      if UIApplication.shared.applicationState == .background {
        self?.sendLocalNotification(contactModel: contactModel)
      }
    }
  }
  
  func sendLocalNotification(contactModel: ContactModel) {
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
