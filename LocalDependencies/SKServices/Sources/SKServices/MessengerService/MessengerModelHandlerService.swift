//
//  MessengerModelHandlerService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle

// MARK: - MessengerModelHandlerService

public final class MessengerModelHandlerService: IMessengerModelHandlerService {
  
  // MARK: - Private properties
  
  private let secureDataManagerService = SecureDataManagerService(.messengerModelHandler)
  private let queue = DispatchQueue(label: "com.sosinvitalii.MessengerModelHandlerServiceQueue")
  
  // MARK: - Init
  
  public init() {}
  
  // MARK: - Public func
  
  public func getMessengerModel() async -> MessengerModel {
    await withCheckedContinuation { continuation in
      queue.async { [weak self] in
        guard let self else { return }
        let messengerModel: MessengerModel
        if let model: MessengerModel? = self.secureDataManagerService.getModel(for: Constants.messengerModelKey),
           let unwrappedModel = model {
          messengerModel = unwrappedModel
        } else {
          messengerModel = MessengerModel.setDefaultValues()
        }
        continuation.resume(returning: messengerModel)
      }
    }
  }
  
  public func clearAllMessenge() async {
    var model = await getMessengerModel()
    var updatedContacts = model.contacts.map { contact -> ContactModel in
      var updatedContact = contact
      updatedContact.messenges = []
      return updatedContact
    }
    model.contacts = updatedContacts
    await saveMessengerModel(model)
  }
  
  public func getContactModels() async -> [ContactModel] {
    let model = await getMessengerModel()
    return model.contacts
  }
  
  public func removeContactModels(_ contactModel: ContactModel) async {
    var model = await getMessengerModel()
    var updatedContactModel: [ContactModel] = model.contacts
    
    if let contactIndex = updatedContactModel.firstIndex(of: contactModel) {
      updatedContactModel.remove(at: contactIndex)
    }
    model.contacts = updatedContactModel
    await saveMessengerModel(model)
  }
  
  public func saveContactModel(_ contactModel: ContactModel) async {
    var model = await getMessengerModel()
    var updatedContactModel: [ContactModel] = model.contacts
    
    if let contactIndex = updatedContactModel.firstIndex(where: { $0.toxAddress == contactModel.toxAddress }) {
      updatedContactModel[contactIndex] = contactModel
    } else {
      updatedContactModel.append(contactModel)
    }
    
    model.contacts = updatedContactModel
    await saveMessengerModel(model)
  }
  
  public func saveContactModels(_ contactModels: [ContactModel]) async {
    var model = await getMessengerModel()
    model.contacts = contactModels
    await saveMessengerModel(model)
  }
  
  @discardableResult
  public func deleteAllData() -> Bool {
    secureDataManagerService.deleteAllData()
  }
  
  public func getAppSettingsModel() async -> AppSettingsModel {
    let safeKeeperModel = await getMessengerModel()
    return safeKeeperModel.appSettingsModel
  }
  
  public func saveAppSettingsModel(_ appSettingsModel: AppSettingsModel) async {
    var model = await getMessengerModel()
    model.appSettingsModel = appSettingsModel
    await saveMessengerModel(model)
  }
}

// MARK: - Funcs

extension MessengerModelHandlerService {
  public func saveMessengerModel(_ model: MessengerModel) async {
    await withCheckedContinuation { continuation in
      queue.async { [weak self] in
        guard let self else { return }
        self.secureDataManagerService.saveModel(model, for: Constants.messengerModelKey)
        continuation.resume()
      }
    }
  }
}

// MARK: - DataStorageType

extension MessengerModelHandlerService {
  /// Перечисление типов хранения данных
  public enum DataStorageType {
    /// Постоянное хранение данных
    case persistent
    
    /// Хранение данных в пределах сессии
    case session
  }
}

// MARK: - Constants

private enum Constants {
  static let messengerModelKey = String(describing: MessengerModel.self)
}
