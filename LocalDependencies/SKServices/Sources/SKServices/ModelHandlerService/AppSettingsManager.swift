//
//  AppSettingsManager.swift
//  SKServices
//
//  Created by Vitalii Sosin on 20.05.2024.
//

import SwiftUI
import SKAbstractions
import SKStyle

// MARK: - IAppSettingsManager

extension ModelHandlerService: IAppSettingsManager {
  public func setIsEnabledFaceID(_ value: Bool, completion: (() -> Void)? = nil) {
    getSafeKeeperModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      updatedModel.appSettingsModel.isFaceIDEnabled = value
      
      DispatchQueue.main.async {
        self.saveSafeKeeperModel(updatedModel, completion: completion)
      }
    }
  }
  
  public func setAppPassword(_ value: String?, completion: (() -> Void)? = nil) {
    getSafeKeeperModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      updatedModel.appSettingsModel.appPassword = value
      
      DispatchQueue.main.async {
        self.saveSafeKeeperModel(updatedModel, completion: completion)
      }
    }
  }
  
  public func setCurrentCurrency(_ value: CurrencyModel, completion: (() -> Void)? = nil) {
    getSafeKeeperModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      updatedModel.appSettingsModel.currentCurrency = value
      
      DispatchQueue.main.async {
        self.saveSafeKeeperModel(updatedModel, completion: completion)
      }
    }
  }
  
  public func setIsEnabledNotifications(_ value: Bool, completion: (() -> Void)? = nil) {
    getSafeKeeperModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      updatedModel.appSettingsModel.isNotificationsEnabled = value
      
      DispatchQueue.main.async {
        self.saveSafeKeeperModel(updatedModel, completion: completion)
      }
    }
  }
}
