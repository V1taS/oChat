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
      saveMessengerModel(updatedModel, completion: completion)
    }
  }
  
  public func setAppPassword(_ value: String?, completion: (() -> Void)? = nil) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      updatedModel.appSettingsModel.appPassword = value
      saveMessengerModel(updatedModel, completion: completion)
    }
  }
  
  public func setIsEnabledNotifications(_ value: Bool, completion: (() -> Void)? = nil) {
    getMessengerModel { [weak self] model in
      guard let self else {
        return
      }
      var updatedModel = model
      updatedModel.appSettingsModel.isNotificationsEnabled = value
      saveMessengerModel(updatedModel, completion: completion)
    }
  }
}
