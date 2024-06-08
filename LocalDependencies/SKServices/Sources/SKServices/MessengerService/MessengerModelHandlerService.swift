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
  
  public func getMessengerModel(completion: @escaping (MessengerModel) -> Void) {
    queue.async { [weak self] in
      guard let self else {
        return
      }
      
      let messengerModel: MessengerModel
      if let model: MessengerModel? = self.secureDataManagerService.getModel(for: Constants.messengerModelKey),
         let unwrappedModel = model {
        messengerModel = unwrappedModel
      } else {
        messengerModel = MessengerModel.setDefaultValues()
      }
      DispatchQueue.main.async {
        completion(messengerModel)
      }
    }
  }
  
  public func saveMessengerModel(_ model: MessengerModel, completion: (() -> Void)?) {
    queue.async(flags: .barrier) { [weak self] in
      guard let self else {
        return
      }
      
      self.secureDataManagerService.saveModel(model, for: Constants.messengerModelKey)
      DispatchQueue.main.async {
        completion?()
      }
    }
  }
  
  public func getContactModels(completion: @escaping ([ContactModel]) -> Void) {
    getMessengerModel { model in
      DispatchQueue.main.async {
        completion(model.contacts)
      }
    }
  }
  
  public func removeContactModels(_ contactModel: ContactModel, completion: (() -> Void)?) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      
      var updatedModel = model
      var updatedContactModel: [ContactModel] = model.contacts
      
      if let contactIndex = updatedContactModel.firstIndex(of: contactModel) {
        updatedContactModel.remove(at: contactIndex)
      }
      updatedModel.contacts = updatedContactModel
      self.saveMessengerModel(updatedModel, completion: completion)
      
      DispatchQueue.main.async {
        completion?()
      }
    }
  }
  
  public func saveContactModel(_ contactModel: ContactModel, completion: (() -> Void)?) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      var updatedContactModel: [ContactModel] = model.contacts
      
      if let contactIndex = updatedContactModel.firstIndex(where: { $0.onionAddress == contactModel.onionAddress }) {
        updatedContactModel[contactIndex] = contactModel
      } else {
        updatedContactModel.append(contactModel)
      }
      
      updatedModel.contacts = updatedContactModel
      self.saveMessengerModel(updatedModel, completion: completion)
    }
  }
  
  public func saveContactModels(_ contactModels: [ContactModel], completion: (() -> Void)?) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      
      var updatedModel = model
      updatedModel.contacts = contactModels
      self.saveMessengerModel(updatedModel, completion: completion)
    }
  }
  
  @discardableResult
  public func deleteAllData() -> Bool {
    secureDataManagerService.deleteAllData()
  }
  
  public func getAppSettingsModel(completion: @escaping (AppSettingsModel) -> Void) {
    getMessengerModel { safeKeeperModel in
      DispatchQueue.main.async {
        completion(safeKeeperModel.appSettingsModel)
      }
    }
  }
  
  public func saveAppSettingsModel(_ appSettingsModel: AppSettingsModel, completion: (() -> Void)? = nil) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      
      var updatedModel = model
      updatedModel.appSettingsModel = appSettingsModel
      
      self.saveMessengerModel(updatedModel, completion: completion)
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let messengerModelKey = String(describing: MessengerModel.self)
}
