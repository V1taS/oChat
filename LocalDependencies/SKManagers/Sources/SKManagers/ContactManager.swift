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
  
  private let contactsDataManager: IContactsDataManager
  private let p2pChatManager: IP2PChatManager
  
  // MARK: - Init
  
  public init(
    contactsDataManager: IContactsDataManager,
    p2pChatManager: IP2PChatManager
  ) {
    self.contactsDataManager = contactsDataManager
    self.p2pChatManager = p2pChatManager
  }
  
  // MARK: - Public func
  
  public func getContactModels() async -> [ContactModel] {
    return await contactsDataManager.getListContactModels()
  }
  
  public func saveContactModel(_ model: ContactModel) async {
    await contactsDataManager.saveContact(model)
  }
  
  public func removeContactModel(_ contactModel: ContactModel) async -> Bool {
    await contactsDataManager.removeContact(contactModel)
    let success = await p2pChatManager.deleteFriend(toxPublicKey: contactModel.toxPublicKey ?? "")
    return success
  }
  
  public func getContactModelFrom(toxAddress: String) async -> ContactModel? {
    let contactModels = await contactsDataManager.getListContactModels()
    return contactModels.first { $0.toxAddress == toxAddress }
  }
  
  public func getContactModelFrom(toxPublicKey: String) async -> ContactModel? {
    let contactModels = await contactsDataManager.getListContactModels()
    return contactModels.first { $0.toxPublicKey == toxPublicKey }
  }
  
  public func setStatus(_ model: ContactModel, _ status: ContactModel.Status) async {
    await contactsDataManager.setStatus(model, status)
  }
  
  public func setAllContactsOffline() async {
    await contactsDataManager.setAllContactsIsOffline()
  }
  
  public func setAllContactsNotTyping() async {
    await contactsDataManager.setAllContactsNoTyping()
  }
}
