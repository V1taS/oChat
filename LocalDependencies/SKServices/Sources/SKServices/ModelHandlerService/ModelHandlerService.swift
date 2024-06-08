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
  
  public func getSafeKeeperModel(completion: @escaping (SafeKeeperModel) -> Void) {
    queue.async { [weak self] in
      guard let self else {
        return
      }
      
      let safeKeeperModel: SafeKeeperModel
      if let model: SafeKeeperModel? = self.secureDataManagerService.getModel(for: Constants.safeKeeperModelKey),
         let unwrappedModel = model {
        safeKeeperModel = unwrappedModel
      } else {
        safeKeeperModel = SafeKeeperModel(
          appSettingsModel: .setDefaultValues(),
          wallets: []
        )
      }
      DispatchQueue.main.async {
        completion(safeKeeperModel)
      }
    }
  }
  
  @discardableResult
  public func deleteAllData() -> Bool {
    secureDataManagerService.deleteAllData()
  }
  
  public func saveSafeKeeperModel(_ model: SafeKeeperModel, completion: (() -> Void)? = nil) {
    queue.async(flags: .barrier) { [weak self] in
      guard let self else {
        return
      }
      
      self.secureDataManagerService.saveModel(model, for: Constants.safeKeeperModelKey)
      DispatchQueue.main.async {
        completion?()
      }
    }
  }
  
  public func getAppSettingsModel(completion: @escaping (AppSettingsModel) -> Void) {
    getSafeKeeperModel { safeKeeperModel in
      DispatchQueue.main.async {
        completion(safeKeeperModel.appSettingsModel)
      }
    }
  }
  
  public func saveAppSettingsModel(_ appSettingsModel: AppSettingsModel, completion: (() -> Void)? = nil) {
    getSafeKeeperModel { [weak self] model in
      guard let self else {
        return
      }
      
      var updatedModel = model
      updatedModel.appSettingsModel = appSettingsModel
      
      self.saveSafeKeeperModel(updatedModel, completion: completion)
    }
  }
  
  public func getWalletModels(completion: @escaping ([WalletModel]) -> Void) {
    getSafeKeeperModel { safeKeeperModel in
      DispatchQueue.main.async {
        completion(safeKeeperModel.wallets)
      }
    }
  }
  
  public func saveWalletModels(_ walletModels: [WalletModel], completion: (() -> Void)? = nil) {
    getSafeKeeperModel { [weak self] model in
      guard let self else {
        return
      }
      
      var updatedModel = model
      updatedModel.wallets = walletModels

      self.saveSafeKeeperModel(updatedModel, completion: completion)
    }
  }
  
  public func saveWalletModel(_ walletModel: WalletModel, completion: (() -> Void)? = nil) {
    getSafeKeeperModel { [weak self] model in
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

      self.saveSafeKeeperModel(updatedModel, completion: completion)
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let safeKeeperModelKey = String(describing: SafeKeeperModel.self)
}
