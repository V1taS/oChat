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
  public func setStatus(
    _ contactModel: ContactModel,
    _ status: ContactModel.Status,
    completion: (() -> Void)?
  ) {
      getMessengerModel { [weak self] model in
        guard let self else {
          return
        }
        var updatedModel = model
        if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
          updatedModel.contacts[contactIndex].status = status
        }
        
        self.saveMessengerModel(updatedModel, completion: completion)
      }
    }
  
  public func setIsPasswordDialogProtected(
    _ contactModel: ContactModel,
   _ value: Bool,
   completion: (() -> Void)?
  ) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        updatedModel.contacts[contactIndex].isPasswordDialogProtected = value
      }
      
      self.saveMessengerModel(updatedModel, completion: completion)
    }
  }
  
  public func setNameContact(
    _ contactModel: ContactModel,
    _ name: String,
    completion: ((ContactModel?) -> Void)?
  ) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      var updatedContactModel = contactModel
      updatedContactModel.name = name
      
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        updatedModel.contacts[contactIndex].name = name
      }
      
      self.saveMessengerModel(
        updatedModel,
        completion: {
          completion?(updatedContactModel)
        }
      )
    }
  }
  
  public func setOnionAddress(
    _ contactModel: ContactModel,
    _ address: String,
    completion: ((ContactModel?) -> Void)?
  ) {
      getMessengerModel { [weak self] model in
        guard let self else {
          return
        }
        var updatedModel = model
        var updatedContactModel = contactModel
        updatedContactModel.onionAddress = address
        
        if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
          updatedModel.contacts[contactIndex].onionAddress = address
        }
        
        self.saveMessengerModel(
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
      guard let self else {
        return
      }
      var updatedModel = model
      var updatedContactModel = contactModel
      updatedContactModel.meshAddress = meshAddress
      
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        updatedModel.contacts[contactIndex].meshAddress = meshAddress
      }
      
      self.saveMessengerModel(
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
      guard let self else {
        return
      }
      var updatedModel = model
      var updatedContactModel: ContactModel?
      
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        var contactModelTemp = contactModel
        contactModelTemp.messenges.append(messengeModel)
        updatedContactModel = contactModelTemp
        updatedModel.contacts[contactIndex].messenges.append(messengeModel)
      }
      
      self.saveMessengerModel(
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
      guard let self else {
        return
      }
      var updatedModel = model
      var updatedContactModel = contactModel
      updatedContactModel.encryptionPublicKey = publicKey
      
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        updatedModel.contacts[contactIndex].encryptionPublicKey = publicKey
      }
      
      self.saveMessengerModel(
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
      guard let self else {
        return
      }
      var updatedModel = model
      
      if let contactIndex = updatedModel.contacts.firstIndex(of: contactModel) {
        updatedModel.contacts.remove(at: contactIndex)
      }
      
      self.saveMessengerModel(
        updatedModel,
        completion: completion
      )
    }
  }
}
