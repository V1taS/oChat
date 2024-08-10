//
//  MessengeDataManager.swift
//  SKServices
//
//  Created by Vitalii Sosin on 10.08.2024.
//

import Foundation
import SwiftUI
import SKAbstractions
import SKStyle

// MARK: - MessengeDataManager

public final class MessengeDataManager: IMessengeDataManager {
  
  // MARK: - Public properties
  
  public static let shared = MessengeDataManager()
  
  // MARK: - Private properties
  
  private var messengeData = SecureDataManagerService(.messengeData)
  private let queueMessenge = DispatchQueue(label: "com.sosinvitalii.MessengeDataQueue")
  
  // MARK: - Init
  
  private init() {}
  
  public func getDictionaryMessengeModels() async -> MessengeModels {
    await withCheckedContinuation { continuation in
      queueMessenge.async { [weak self] in
        guard let self else { return }
        let messengeModels: MessengeModels
        if let models: MessengeModels = messengeData.getModel(for: Constants.messengeDataManagerKey) {
          messengeModels = models
        } else {
          messengeModels = [:]
        }
        continuation.resume(returning: messengeModels)
      }
    }
  }
  
  public func saveMessengeModels(_ models: MessengeModels) async {
    await withCheckedContinuation { continuation in
      queueMessenge.async { [weak self] in
        guard let self else { return }
        messengeData.saveModel(models, for: Constants.messengeDataManagerKey)
        continuation.resume()
      }
    }
  }
  
  public func clearAllMessenge() async {
    await withCheckedContinuation { continuation in
      queueMessenge.async { [weak self] in
        guard let self else { return }
        let models: MessengeModels = [:]
        messengeData.saveModel(models, for: Constants.messengeDataManagerKey)
        continuation.resume()
      }
    }
  }
  
  public func addMessenge(_ contactID: String, _ messengeModel: MessengeModel) async {
    var updatedDictionaryContactModels: MessengeModels = await getDictionaryMessengeModels()
    var messengeModels: [MessengeModel] = updatedDictionaryContactModels[contactID] ?? []
    messengeModels.append(messengeModel)
    updatedDictionaryContactModels.updateValue(messengeModels, forKey: contactID)
    await saveMessengeModels(updatedDictionaryContactModels)
  }
  
  public func getMessengeModelsFor(_ contactID: String) async -> [MessengeModel] {
    var updatedDictionaryContactModels: MessengeModels = await getDictionaryMessengeModels()
    return updatedDictionaryContactModels[contactID] ?? []
  }
  
  public func removeMessenge(_ contactModel: ContactModel, _ id: String) async {
    var updatedDictionaryContactModels: MessengeModels = await getDictionaryMessengeModels()
    updatedDictionaryContactModels.removeValue(forKey: id)
    await saveMessengeModels(updatedDictionaryContactModels)
  }
  
  public func removeMessenges(_ contactModel: ContactModel) async {
    var updatedDictionaryContactModels: MessengeModels = await getDictionaryMessengeModels()
    updatedDictionaryContactModels.removeValue(forKey: contactModel.id)
    await saveMessengeModels(updatedDictionaryContactModels)
  }
  
  public func updateMessenge(_ contactModel: ContactModel, _ messengeModel: MessengeModel) async {
    var updatedDictionaryContactModels: MessengeModels = await getDictionaryMessengeModels()
    if var messengeModels = updatedDictionaryContactModels[contactModel.id],
       let messengeModelIndex = messengeModels.firstIndex(where: {$0.id == messengeModel.id }) {
      messengeModels[messengeModelIndex] = messengeModel
      updatedDictionaryContactModels.updateValue(messengeModels, forKey: contactModel.id)
    }
    await saveMessengeModels(updatedDictionaryContactModels)
  }

  public func clearAllMessengeTempID() async {
    var updatedDictionaryContactModels: MessengeModels = await getDictionaryMessengeModels()
    updatedDictionaryContactModels = updatedDictionaryContactModels.mapValues { messenges in
      messenges.map { messenge in
        var messenge = messenge
        messenge.tempMessageID = nil
        return messenge
      }
    }
    await saveMessengeModels(updatedDictionaryContactModels)
  }
  
  public func getListMessengeModels(_ contactModel: ContactModel) async -> [MessengeModel] {
    var dictionaryMessengeModels: MessengeModels = await getDictionaryMessengeModels()
    if let messengeModels = dictionaryMessengeModels[contactModel.id] {
      return messengeModels
    }
    return []
  }
}

// MARK: - Constants

private enum Constants {
  static let messengeDataManagerKey = String(describing: MessengeDataManager.self)
}
