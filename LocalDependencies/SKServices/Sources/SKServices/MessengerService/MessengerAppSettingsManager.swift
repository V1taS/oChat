//
//  MessengerAppSettingsManager.swift
//  SKServices
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import Foundation
import SwiftUI
import SKAbstractions
import SKStyle

// MARK: - IAppSettingsManager

extension MessengerModelHandlerService: IAppSettingsManager {
  public func setIsEnabledFaceID(_ value: Bool, completion: (() -> Void)? = nil) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      updatedModel.appSettingsModel.isFaceIDEnabled = value
      
      DispatchQueue.main.async {
        self.saveMessengerModel(updatedModel, completion: completion)
      }
    }
  }
  
  public func setAppPassword(_ value: String?, completion: (() -> Void)? = nil) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      updatedModel.appSettingsModel.appPassword = value
      
      DispatchQueue.main.async {
        self.saveMessengerModel(updatedModel, completion: completion)
      }
    }
  }
  
  public func setCurrentCurrency(_ value: CurrencyModel, completion: (() -> Void)? = nil) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      updatedModel.appSettingsModel.currentCurrency = value
      
      DispatchQueue.main.async {
        self.saveMessengerModel(updatedModel, completion: completion)
      }
    }
  }
  
  public func setIsEnabledNotifications(_ value: Bool, completion: (() -> Void)? = nil) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      updatedModel.appSettingsModel.isNotificationsEnabled = value
      
      DispatchQueue.main.async {
        self.saveMessengerModel(updatedModel, completion: completion)
      }
    }
  }
}
