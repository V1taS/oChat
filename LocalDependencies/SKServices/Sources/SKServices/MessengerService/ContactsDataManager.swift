//
//  ContactsDataManager.swift
//  SKServices
//
//  Created by Vitalii Sosin on 10.08.2024.
//

import Foundation
import SwiftUI
import SKAbstractions
import SKStyle

// MARK: - ContactsDataManager

public final class ContactsDataManager: IContactsDataManager {
  
  // MARK: - Public properties
  
  public static let shared = ContactsDataManager()
  
  // MARK: - Private properties
  
  private var contactsData = SecureDataManagerService(.contactsData)
  private let queueContacts = DispatchQueue(label: "com.sosinvitalii.ContactsDataQueue")
  
  // MARK: - Init
  
  private init() {}
  
  public func getDictionaryContactModels() async -> [String: ContactModel] {
    await withCheckedContinuation { continuation in
      queueContacts.async { [weak self] in
        guard let self else { return }
        let contactModels: ContactModels
        if let model: ContactModels = contactsData.getModel(for: Constants.contactsDataManagerKey) {
          contactModels = model
        } else {
          contactModels = [:]
        }
        continuation.resume(returning: contactModels)
      }
    }
  }
  
  public func getListContactModels() async -> [ContactModel] {
    await withCheckedContinuation { continuation in
      queueContacts.async { [weak self] in
        guard let self else { return }
        let contactModels: [ContactModel]
        if let model: ContactModels = contactsData.getModel(for: Constants.contactsDataManagerKey) {
          let sortedArray = Array(model.values).sorted(by: { $0.dateOfCreation < $1.dateOfCreation })
          contactModels = sortedArray
        } else {
          contactModels = []
        }
        continuation.resume(returning: contactModels)
      }
    }
  }
  
  public func saveContactModels(_ models: ContactModels) async {
    await withCheckedContinuation { continuation in
      queueContacts.async { [weak self] in
        guard let self else { return }
        contactsData.saveModel(models, for: Constants.contactsDataManagerKey)
        continuation.resume()
      }
    }
  }
  
  public func removeContact(_ contactModel: ContactModel) async {
    var updatedDictionaryContactModels: ContactModels = await getDictionaryContactModels()
    if updatedDictionaryContactModels.keys.contains(contactModel.id) {
      updatedDictionaryContactModels.removeValue(forKey: contactModel.id)
    }
    await saveContactModels(updatedDictionaryContactModels)
  }
  
  public func saveContact(_ contactModel: ContactModel) async {
    var updatedDictionaryContactModels: ContactModels = await getDictionaryContactModels()
    updatedDictionaryContactModels.updateValue(contactModel, forKey: contactModel.id)
    await saveContactModels(updatedDictionaryContactModels)
  }
  
  public func setIsNewMessagesAvailable(_ value: Bool, id: String) async {
    var updatedDictionaryContactModels: ContactModels = await getDictionaryContactModels()
    if updatedDictionaryContactModels.keys.contains(id) {
      updatedDictionaryContactModels[id]?.isNewMessagesAvailable = value
    }
    await saveContactModels(updatedDictionaryContactModels)
  }
  
  public func setEncryptionPublicKey(_ contactModel: ContactModel, _ publicKey: String) async -> ContactModel? {
    var updatedDictionaryContactModels: ContactModels = await getDictionaryContactModels()
    var updatedContactModel = contactModel
    updatedContactModel.encryptionPublicKey = publicKey
    updatedDictionaryContactModels.updateValue(updatedContactModel, forKey: contactModel.id)
    await saveContactModels(updatedDictionaryContactModels)
    return updatedContactModel
  }
  
  public func setMeshAddress(_ contactModel: ContactModel, _ meshAddress: String) async -> ContactModel? {
    var updatedDictionaryContactModels: ContactModels = await getDictionaryContactModels()
    var updatedContactModel = contactModel
    updatedContactModel.meshAddress = meshAddress
    updatedDictionaryContactModels.updateValue(updatedContactModel, forKey: contactModel.id)
    await saveContactModels(updatedDictionaryContactModels)
    return updatedContactModel
  }
  
  public func setToxAddress(_ contactModel: ContactModel, _ address: String) async -> ContactModel? {
    var updatedDictionaryContactModels: ContactModels = await getDictionaryContactModels()
    var updatedContactModel = contactModel
    updatedContactModel.toxAddress = address
    updatedDictionaryContactModels.updateValue(updatedContactModel, forKey: contactModel.id)
    await saveContactModels(updatedDictionaryContactModels)
    return updatedContactModel
  }
  
  public func setNameContact(_ contactModel: ContactModel, _ name: String) async -> ContactModel? {
    var updatedDictionaryContactModels: ContactModels = await getDictionaryContactModels()
    var updatedContactModel = contactModel
    updatedContactModel.name = name
    updatedDictionaryContactModels.updateValue(updatedContactModel, forKey: contactModel.id)
    await saveContactModels(updatedDictionaryContactModels)
    return updatedContactModel
  }
  
  public func setAllContactsNoTyping() async {
    var updatedDictionaryContactModels: ContactModels = await getDictionaryContactModels()
    updatedDictionaryContactModels = updatedDictionaryContactModels.mapValues { contact -> ContactModel in
      var updatedContact = contact
      if contact.isTyping { updatedContact.isTyping = false }
      return updatedContact
    }
    await saveContactModels(updatedDictionaryContactModels)
  }
  
  public func setAllContactsIsOffline() async {
    var updatedDictionaryContactModels: ContactModels = await getDictionaryContactModels()
    updatedDictionaryContactModels = updatedDictionaryContactModels.mapValues { contact -> ContactModel in
      var updatedContact = contact
      if contact.status == .online { updatedContact.status = .offline }
      return updatedContact
    }
    await saveContactModels(updatedDictionaryContactModels)
  }
  
  public func setStatus(_ contactModel: ContactModel, _ status: ContactModel.Status) async {
    var updatedDictionaryContactModels: ContactModels = await getDictionaryContactModels()
    if updatedDictionaryContactModels.keys.contains(contactModel.id) {
      updatedDictionaryContactModels[contactModel.id]?.status = status
    }
    await saveContactModels(updatedDictionaryContactModels)
  }
}

// MARK: - Constants

private enum Constants {
  static let contactsDataManagerKey = String(describing: ContactsDataManager.self)
}
