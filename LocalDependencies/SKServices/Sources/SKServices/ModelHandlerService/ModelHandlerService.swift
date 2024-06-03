//
//  ModelHandlerService.swift
//  SKServices
//
//  Created by Vitalii Sosin on 18.05.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle

// MARK: - ModelHandlerService

public final class ModelHandlerService: IModelHandlerService {
  
  // MARK: - Private properties
  
  private let secureDataManagerService = SecureDataManagerService(.modelHandler)
  private let queue = DispatchQueue(label: "com.sosinvitalii.ModelHandlerServiceQueue")
  
  // MARK: - Init
  
  public init() {}
  
  // MARK: - Public func
  
  public func getoChatModel(completion: @escaping (oChatModel) -> Void) {
    queue.async { [weak self] in
      guard let self else {
        return
      }
      
      let updateModel: oChatModel
      if let model: oChatModel? = self.secureDataManagerService.getModel(for: Constants.oChatModelKey),
         let unwrappedModel = model {
        updateModel = unwrappedModel
      } else {
        updateModel = oChatModel(
          appSettingsModel: .setDefaultValues(),
          wallets: []
        )
      }
      DispatchQueue.main.async {
        completion(updateModel)
      }
    }
  }
  
  @discardableResult
  public func deleteAllData() -> Bool {
    secureDataManagerService.deleteAllData()
  }
  
  public func saveoChatModel(_ model: oChatModel, completion: (() -> Void)? = nil) {
    queue.async(flags: .barrier) { [weak self] in
      guard let self else {
        return
      }
      
      self.secureDataManagerService.saveModel(model, for: Constants.oChatModelKey)
      DispatchQueue.main.async {
        completion?()
      }
    }
  }
  
  public func getAppSettingsModel(completion: @escaping (AppSettingsModel) -> Void) {
    getoChatModel { oChatModel in
      DispatchQueue.main.async {
        completion(oChatModel.appSettingsModel)
      }
    }
  }
  
  public func saveAppSettingsModel(_ appSettingsModel: AppSettingsModel, completion: (() -> Void)? = nil) {
    getoChatModel { [weak self] model in
      guard let self else {
        return
      }
      
      var updatedModel = model
      updatedModel.appSettingsModel = appSettingsModel
      
      self.saveoChatModel(updatedModel, completion: completion)
    }
  }
  
  public func getWalletModels(completion: @escaping ([WalletModel]) -> Void) {
    getoChatModel { oChatModel in
      DispatchQueue.main.async {
        completion(oChatModel.wallets)
      }
    }
  }
  
  public func saveWalletModels(_ walletModels: [WalletModel], completion: (() -> Void)? = nil) {
    getoChatModel { [weak self] model in
      guard let self else {
        return
      }
      
      var updatedModel = model
      updatedModel.wallets = walletModels

      self.saveoChatModel(updatedModel, completion: completion)
    }
  }
  
  public func saveWalletModel(_ walletModel: WalletModel, completion: (() -> Void)? = nil) {
    getoChatModel { [weak self] model in
      guard let self else {
        return
      }
      
      var wallets: [WalletModel] = []
      
      if walletModel.isPrimary {
        wallets = model.wallets.compactMap {
          var updatedModel = $0
          updatedModel.isPrimary = false
          return updatedModel
        }
        wallets.append(walletModel)
      } else {
        wallets = model.wallets
        wallets.append(walletModel)
      }
      
      var updatedModel = model
      updatedModel.wallets = wallets

      self.saveoChatModel(updatedModel, completion: completion)
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let oChatModelKey = String(describing: oChatModel.self)
}
