//
//  ConfigurationValueConfigurator.swift
//  oChat
//
//  Created by Vitalii Sosin on 12.05.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import SKUIKit
import UIKit
import SKStyle

struct ConfigurationValueConfigurator: Configurator {
  
  // MARK: - Private properties
  
  private let services: IApplicationServices
  private var cloudKitService: ICloudKitService {
    services.cloudKitService
  }
  private var secureDataManagerService: ISecureDataManagerService {
    services.dataManagementService.getSecureDataManagerService(.configurationSecrets)
  }
  
  // MARK: - Init
  
  init(services: IApplicationServices) {
    self.services = services
  }
  
  // MARK: - Internal func
  
  func configure() {
    getPushNotificationAuthKey()
    getPushNotificationKeyID()
    getPushNotificationProdURL()
    getPushNotificationTeamID()
    getPushNotificationTestURL()
    getSupportOChatMail()
  }
}

// MARK: - Private

private extension ConfigurationValueConfigurator {
  func getPushNotificationAuthKey() {
    getConfigurationValue(forKey: Constants.pushNotificationAuthKey) { value in
      Secrets.pushNotificationAuthKey = value
    }
  }
  
  func getPushNotificationKeyID() {
    getConfigurationValue(forKey: Constants.pushNotificationKeyID) { value in
      Secrets.pushNotificationKeyID = value
    }
  }
  
  func getPushNotificationProdURL() {
    getConfigurationValue(forKey: Constants.pushNotificationProdURL) { value in
      Secrets.pushNotificationProdURL = value
    }
  }
  
  func getPushNotificationTeamID() {
    getConfigurationValue(forKey: Constants.pushNotificationTeamID) { value in
      Secrets.pushNotificationTeamID = value
    }
  }
  
  func getPushNotificationTestURL() {
    getConfigurationValue(forKey: Constants.ushNotificationTestURL) { value in
      Secrets.ushNotificationTestURL = value
    }
  }
  
  func getSupportOChatMail() {
    getConfigurationValue(forKey: Constants.supportOChatMail) { value in
      Secrets.supportOChatMail = value
    }
  }
  
  func getConfigurationValue(forKey key: String, completion: @escaping (String) -> Void) {
    if let value = secureDataManagerService.getString(for: key) {
      completion(value)
    }
    
    Task {
      let value: String? = try? await cloudKitService.getConfigurationValue(from: key)
      if let value {
        completion(value)
        secureDataManagerService.saveString(value, key: key)
      }
    }
  }
}

// MARK: - Private

private enum Constants {
  static let pushNotificationAuthKey = "PushNotificationAuthKey"
  static let pushNotificationKeyID = "PushNotificationKeyID"
  static let pushNotificationProdURL = "PushNotificationProdURL"
  static let pushNotificationTeamID = "PushNotificationTeamID"
  static let ushNotificationTestURL = "PushNotificationTestURL"
  static let supportOChatMail = "SupportOChatMail"
}
