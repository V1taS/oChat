//
//  ContactManager.swift
//  SKManagers
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle

public final class ContactManager: IContactManager {
  
  // MARK: - Private properties
  
  private let modelHandlerService: IMessengerModelHandlerService
  private let modelSettingsManager: IMessengerModelSettingsManager
  private let p2pChatManager: IP2PChatManager
  
  // MARK: - Init
  
  public init(
    modelHandlerService: IMessengerModelHandlerService,
    modelSettingsManager: IMessengerModelSettingsManager,
    p2pChatManager: IP2PChatManager
  ) {
    self.modelHandlerService = modelHandlerService
    self.modelSettingsManager = modelSettingsManager
    self.p2pChatManager = p2pChatManager
  }
  
  // MARK: - Public func
  
  public func getContactModels() async -> [ContactModel] {
    return await modelHandlerService.getContactModels()
  }
  
  public func saveContactModel(_ model: ContactModel) async {
    await modelHandlerService.saveContactModel(model)
  }
  
  public func removeContactModel(_ contactModel: ContactModel) async -> Bool {
    await modelHandlerService.removeContactModels(contactModel)
    let success = await p2pChatManager.deleteFriend(toxPublicKey: contactModel.toxPublicKey ?? "")
    return success
  }
  
  public func getContactModelFrom(toxAddress: String) async -> ContactModel? {
    let contactModels = await modelHandlerService.getContactModels()
    return contactModels.first { $0.toxAddress == toxAddress }
  }
  
  public func getContactModelFrom(toxPublicKey: String) async -> ContactModel? {
    let contactModels = await modelHandlerService.getContactModels()
    return contactModels.first { $0.toxPublicKey == toxPublicKey }
  }
  
  public func setStatus(_ model: ContactModel, _ status: ContactModel.Status) async {
    await modelSettingsManager.setStatus(model, status)
  }
  
  public func setAllContactsOffline() async {
    await modelSettingsManager.setAllContactsIsOffline()
  }
  
  public func setAllContactsNotTyping() async {
    await modelSettingsManager.setAllContactsNoTyping()
  }
  
  public func clearAllMessengeTempID() async {
    await modelSettingsManager.clearAllMessengeTempID()
  }
}