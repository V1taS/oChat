//
//  ModelSettingsManager.swift
//  SKServices
//
//  Created by Vitalii Sosin on 20.05.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle

// MARK: - IModelSettingsManager

extension ModelHandlerService: IModelSettingsManager {
  public func deleteWallet(
    _ model: WalletModel,
    completion: (() -> Void)?
  ) {
    getSafeKeeperModel { [weak self] oldModel in
      guard let self else {
        return
      }
      var oldWallets = oldModel.wallets
      guard let currentWalletIndex = oldWallets.firstIndex(of: model) else {
        DispatchQueue.main.async {
          completion?()
        }
        return
      }
      oldWallets.remove(at: currentWalletIndex)
      
      if oldWallets.filter({ $0.isPrimary }).first == nil,
         let firstWallet = oldWallets.first {
        updateWallet(at: .zero, with: firstWallet, isPrimary: true, in: &oldWallets)
      }
      
      let newModel = SafeKeeperModel(
        appSettingsModel: oldModel.appSettingsModel,
        wallets: oldWallets
      )
      self.saveSafeKeeperModel(newModel, completion: completion)
    }
  }
  
  public func setNameWallet(
    _ walletModel: WalletModel,
    _ name: String,
    completion: ((_ model: WalletModel?) -> Void)?
  ) {
    getSafeKeeperModel { [weak self] oldModel in
      guard let self else {
        return
      }
      var oldWallets = oldModel.wallets
      guard let currentWalletIndex = oldWallets.firstIndex(of: walletModel) else {
        DispatchQueue.main.async {
          completion?(nil)
        }
        return
      }
      
      var updatedModel = walletModel
      updatedModel.name = name
      
      oldWallets.remove(at: currentWalletIndex)
      oldWallets.insert(updatedModel, at: currentWalletIndex)
      
      let newModel = SafeKeeperModel(
        appSettingsModel: oldModel.appSettingsModel,
        wallets: oldWallets
      )
      
      self.saveSafeKeeperModel(
        newModel,
        completion: {
          completion?(updatedModel)
        }
      )
    }
  }
  
  public func setIsPrimaryWallet(
    _ model: WalletModel,
    _ value: Bool,
    completion: (() -> Void)?
  ) {
    getSafeKeeperModel { [weak self] oldModel in
      guard let self else {
        return
      }
      
      var oldWallets = oldModel.wallets
      guard let currentWalletIndex = oldWallets.firstIndex(of: model) else {
        DispatchQueue.main.async {
          completion?()
        }
        return
      }
      
      // Если в массиве один кошелек, то отключить isPrimary нельзя
      if oldWallets.count <= 1 {
        updateWallet(at: currentWalletIndex, with: model, isPrimary: true, in: &oldWallets)
      } else {
        // Устанавливаем все кошельки неосновными
        for i in 0..<oldWallets.count {
          updateWallet(at: i, with: oldWallets[i], isPrimary: false, in: &oldWallets)
        }
        // Устанавливаем выбранный кошелек основным, если значение true
        if value {
          updateWallet(at: currentWalletIndex, with: model, isPrimary: true, in: &oldWallets)
        } else {
          guard let otherWalletIndex = oldWallets.firstIndex(where: { $0.id != model.id }) else {
            DispatchQueue.main.async {
              completion?()
            }
            return
          }
          updateWallet(at: otherWalletIndex, with: oldWallets[otherWalletIndex], isPrimary: true, in: &oldWallets)
        }
      }
      
      let newModel = SafeKeeperModel(
        appSettingsModel: oldModel.appSettingsModel,
        wallets: oldWallets
      )
      
      self.saveSafeKeeperModel(newModel, completion: completion)
    }
  }
}

// MARK: - Private

private extension ModelHandlerService {
  func updateWallet(
    at index: Int,
    with model: WalletModel,
    isPrimary: Bool,
    in wallets: inout [WalletModel]
  ) {
    var updatedModel = model
    updatedModel.isPrimary = isPrimary
    wallets[index] = updatedModel
  }
}
