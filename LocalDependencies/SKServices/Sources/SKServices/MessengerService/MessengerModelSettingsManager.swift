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
  public func saveMyPushNotificationToken(_ token: String, completion: (() -> Void)?) {
    getMessengerModel { [weak self] model in
      guard let self else { return }
      var updatedModel = model
      updatedModel.pushNotificationToken = token
      saveMessengerModel(updatedModel, completion: completion)
    }
  }
  
  public func setToxStateAsString(
    _ toxStateAsString: String?,
    completion: (() -> Void)?
  ) {
    getMessengerModel { [weak self] model in
      guard let self else { return }
      var updatedModel = model
      updatedModel.toxStateAsString = toxStateAsString
      saveMessengerModel(updatedModel, completion: completion)
    }
  }
  
  public func setStatus(
    _ contactModel: ContactModel,
    _ status: ContactModel.Status,
    completion: (() -> Void)?
  ) {
    getMessengerModel { [weak self] model in
      guard let self else { return }
      var updatedModel = model
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        updatedModel.contacts[contactIndex].status = status
      }
      
      saveMessengerModel(updatedModel, completion: completion)
    }
  }
  
  public func setAllContactsIsOffline(completion: (() -> Void)?) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      var updatedContacts = model.contacts.compactMap { model in
        var updatedModel = model
        if model.status == .online {
          updatedModel.status = .offline
        }
        return updatedModel
      }
      updatedModel.contacts = updatedContacts
      saveMessengerModel(updatedModel, completion: completion)
    }
  }
  
  public func setAllContactsNoTyping(completion: (() -> Void)?) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      var updatedContacts = model.contacts.compactMap { model in
        var updatedModel = model
        if model.isTyping {
          updatedModel.isTyping = false
        }
        return updatedModel
      }
      updatedModel.contacts = updatedContacts
      saveMessengerModel(updatedModel, completion: completion)
    }
  }
  
  public func clearAllMessengeTempID(completion: (() -> Void)?) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      var updatedContacts = model.contacts.compactMap { contact in
        var updatedContact = contact
        var updatedMessenges = updatedContact.messenges.compactMap { messenge in
          var updatedMessenge = messenge
          updatedMessenge.tempMessageID = nil
          return updatedMessenge
        }
        updatedContact.messenges = updatedMessenges
        return updatedContact
      }
      updatedModel.contacts = updatedContacts
      saveMessengerModel(updatedModel, completion: completion)
    }
  }
  
  public func setNameContact(
    _ contactModel: ContactModel,
    _ name: String,
    completion: ((ContactModel?) -> Void)?
  ) {
    getMessengerModel { [weak self] model in
      guard let self else { return }
      var updatedModel = model
      var updatedContactModel = contactModel
      updatedContactModel.name = name
      
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        updatedModel.contacts[contactIndex].name = name
      }
      
      saveMessengerModel(
        updatedModel,
        completion: {
          completion?(updatedContactModel)
        }
      )
    }
  }
  
  public func setToxAddress(
    _ contactModel: ContactModel,
    _ address: String,
    completion: ((ContactModel?) -> Void)?
  ) {
    getMessengerModel { [weak self] model in
      guard let self else { return }
      var updatedModel = model
      var updatedContactModel = contactModel
      updatedContactModel.toxAddress = address
      
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        updatedModel.contacts[contactIndex].toxAddress = address
      }
      
      saveMessengerModel(
        updatedModel,
        completion: {
          completion?(updatedContactModel)
        }
      )
    }
  }
  
  public func setMeshAddress(
    _ contactModel: ContactModel,
    _ meshAddress: String,
    completion: ((ContactModel?) -> Void)?
  ) {
    getMessengerModel { [weak self] model in
      guard let self else { return }
      var updatedModel = model
      var updatedContactModel = contactModel
      updatedContactModel.meshAddress = meshAddress
      
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        updatedModel.contacts[contactIndex].meshAddress = meshAddress
      }
      
      saveMessengerModel(
        updatedModel,
        completion: {
          completion?(updatedContactModel)
        }
      )
    }
  }
  
  public func addMessenge(
    _ contactModel: ContactModel,
    _ messengeModel: MessengeModel,
    completion: ((ContactModel?) -> Void)?
  ) {
    getMessengerModel { [weak self] model in
      guard let self else { return }
      var updatedModel = model
      var updatedContactModel: ContactModel?
      
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        var contactModelTemp = contactModel
        contactModelTemp.messenges.append(messengeModel)
        updatedContactModel = contactModelTemp
        updatedModel.contacts[contactIndex].messenges.append(messengeModel)
      }
      
      saveMessengerModel(
        updatedModel,
        completion: {
          completion?(updatedContactModel)
        }
      )
    }
  }
  
  public func setEncryptionPublicKey(
    _ contactModel: ContactModel,
    _ publicKey: String,
    completion: ((ContactModel?) -> Void)?
  ) {
    getMessengerModel { [weak self] model in
      guard let self else { return }
      var updatedModel = model
      var updatedContactModel = contactModel
      updatedContactModel.encryptionPublicKey = publicKey
      
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        updatedModel.contacts[contactIndex].encryptionPublicKey = publicKey
      }
      
      saveMessengerModel(
        updatedModel,
        completion: {
          completion?(updatedContactModel)
        }
      )
    }
  }
  
  public func deleteContact(
    _ contactModel: ContactModel,
    completion: (() -> Void)?
  ) {
    getMessengerModel { [weak self] model in
      guard let self else { return }
      var updatedModel = model
      
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        updatedModel.contacts.remove(at: contactIndex)
      }
      
      saveMessengerModel(updatedModel, completion: completion)
    }
  }
}
