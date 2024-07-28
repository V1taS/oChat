//
//  MessengerAppSettingsManager.swift
//  SKServices
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import Foundation
import SwiftUI
import SKAbstractions
import SKStyle

// MARK: - IAppSettingsManager

extension MessengerModelHandlerService: IAppSettingsManager {
  public func setAppPassword(_ value: String?) async {
    var model = await getMessengerModel()
    model.appSettingsModel.appPassword = value
    await saveMessengerModel(model)
  }
  
  public func setFakeAppPassword(_ value: String?) async {
    var model = await getMessengerModel()
    model.appSettingsModel.fakeAppPassword = value
    await saveMessengerModel(model)
  }
  
  public func setIsFakeAccessEnabled(_ value: Bool) async {
    var model = await getMessengerModel()
    model.appSettingsModel.isFakeAccessEnabled = value
    await saveMessengerModel(model)
  }
  
  public func setIsPremiumEnabled(_ value: Bool) async {
    var model = await getMessengerModel()
    model.appSettingsModel.isPremiumEnabled = value
    await saveMessengerModel(model)
  }
  
  public func setIsTypingIndicatorEnabled(_ value: Bool) async {
    var model = await getMessengerModel()
    model.appSettingsModel.isTypingIndicatorEnabled = value
    await saveMessengerModel(model)
  }
  
  public func setCanSaveMedia(_ value: Bool) async {
    var model = await getMessengerModel()
    model.appSettingsModel.canSaveMedia = value
    await saveMessengerModel(model)
  }
  
  public func setIsChatHistoryStored(_ value: Bool) async {
    var model = await getMessengerModel()
    model.appSettingsModel.isChatHistoryStored = value
    await saveMessengerModel(model)
  }
  
  public func setIsVoiceChangerEnabled(_ value: Bool) async {
    var model = await getMessengerModel()
    model.appSettingsModel.isVoiceChangerEnabled = value
    await saveMessengerModel(model)
  }
  
  public func setIsEnabledNotifications(_ value: Bool) async {
    var model = await getMessengerModel()
    model.appSettingsModel.isNotificationsEnabled = value
    await saveMessengerModel(model)
  }
  
  public func setIsNewMessagesAvailable(_ value: Bool, toxAddress: String) async {
    var model = await getMessengerModel()
    var updatedContacts = model.contacts
    
    if let contactIndex = updatedContacts.firstIndex(where: { $0.toxAddress == toxAddress }) {
      updatedContacts[contactIndex].isNewMessagesAvailable = value
    }
    model.contacts = updatedContacts
    await saveMessengerModel(model)
  }
}
