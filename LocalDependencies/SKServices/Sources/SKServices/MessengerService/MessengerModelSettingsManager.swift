//
//  MessengerModelSettingsManager.swift
//  SKServices
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle

// MARK: - MessengerModelSettingsManager

extension MessengerModelHandlerService: IMessengerModelSettingsManager {
  public func saveMyPushNotificationToken(_ token: String) async {
    var model = await getMessengerModel()
    model.appSettingsModel.pushNotificationToken = token
    await saveMessengerModel(model)
  }
  
  public func setToxStateAsString(_ toxStateAsString: String?) async {
    var model = await getMessengerModel()
    model.appSettingsModel.toxStateAsString = toxStateAsString
    await saveMessengerModel(model)
  }
  
  public func setStatus(_ contactModel: ContactModel, _ status: ContactModel.Status) async {
    var model = await getMessengerModel()
    if let contactIndex = model.contacts.firstIndex(of: contactModel) {
      model.contacts[contactIndex].status = status
    }
    await saveMessengerModel(model)
  }
  
  public func setAllContactsIsOffline() async {
    var model = await getMessengerModel()
    var updatedContacts = model.contacts.map { contact -> ContactModel in
      var updatedContact = contact
      if contact.status == .online {
        updatedContact.status = .offline
      }
      return updatedContact
    }
    model.contacts = updatedContacts
    await saveMessengerModel(model)
  }
  
  public func setAllContactsNoTyping() async {
    var model = await getMessengerModel()
    var updatedContacts = model.contacts.map { contact -> ContactModel in
      var updatedContact = contact
      if contact.isTyping {
        updatedContact.isTyping = false
      }
      return updatedContact
    }
    model.contacts = updatedContacts
    await saveMessengerModel(model)
  }
  
  public func clearAllMessengeTempID() async {
    var model = await getMessengerModel()
    var updatedContacts = model.contacts.map { contact -> ContactModel in
      var updatedContact = contact
      updatedContact.messenges = contact.messenges.map { messenge in
        var updatedMessenge = messenge
        updatedMessenge.tempMessageID = nil
        return updatedMessenge
      }
      return updatedContact
    }
    model.contacts = updatedContacts
    await saveMessengerModel(model)
  }
  
  public func setNameContact(_ contactModel: ContactModel, _ name: String) async -> ContactModel? {
    var model = await getMessengerModel()
    var updatedContactModel = contactModel
    updatedContactModel.name = name
    
    if let contactIndex = model.contacts.firstIndex(of: contactModel) {
      model.contacts[contactIndex].name = name
    }
    
    await saveMessengerModel(model)
    return updatedContactModel
  }
  
  public func setToxAddress(_ contactModel: ContactModel, _ address: String) async -> ContactModel? {
    var model = await getMessengerModel()
    var updatedContactModel = contactModel
    updatedContactModel.toxAddress = address
    
    if let contactIndex = model.contacts.firstIndex(of: contactModel) {
      model.contacts[contactIndex].toxAddress = address
    }
    
    await saveMessengerModel(model)
    return updatedContactModel
  }
  
  public func setMeshAddress(_ contactModel: ContactModel, _ meshAddress: String) async -> ContactModel? {
    var model = await getMessengerModel()
    var updatedContactModel = contactModel
    updatedContactModel.meshAddress = meshAddress
    
    if let contactIndex = model.contacts.firstIndex(of: contactModel) {
      model.contacts[contactIndex].meshAddress = meshAddress
    }
    
    await saveMessengerModel(model)
    return updatedContactModel
  }
  
  public func addMessenge(_ contactModel: ContactModel, _ messengeModel: MessengeModel) async -> ContactModel? {
    var model = await getMessengerModel()
    var updatedContactModel: ContactModel?
    
    if let contactIndex = model.contacts.firstIndex(of: contactModel) {
      var contactModelTemp = contactModel
      contactModelTemp.messenges.append(messengeModel)
      updatedContactModel = contactModelTemp
      model.contacts[contactIndex].messenges.append(messengeModel)
    }
    
    await saveMessengerModel(model)
    return updatedContactModel
  }
  
  public func setEncryptionPublicKey(_ contactModel: ContactModel, _ publicKey: String) async -> ContactModel? {
    var model = await getMessengerModel()
    var updatedContactModel = contactModel
    updatedContactModel.encryptionPublicKey = publicKey
    
    if let contactIndex = model.contacts.firstIndex(of: contactModel) {
      model.contacts[contactIndex].encryptionPublicKey = publicKey
    }
    
    await saveMessengerModel(model)
    return updatedContactModel
  }
  
  public func deleteContact(_ contactModel: ContactModel) async {
    var model = await getMessengerModel()
    
    if let contactIndex = model.contacts.firstIndex(of: contactModel) {
      model.contacts.remove(at: contactIndex)
    }
    
    await saveMessengerModel(model)
  }
}
