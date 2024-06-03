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
    getConfigurationValue(forKey: Constants.oneInchKeys) { value in
      Secrets.oneInchKeys = value
    }
    getConfigurationValue(forKey: Constants.infuraKey) { value in
      Secrets.infuraKeys = value
    }
    getConfigurationValue(forKey: Constants.tokenBaseUrlKey) { value in
      Secrets.tokenBaseUrlString = value
    }
  }
}

// MARK: - Private

private extension ConfigurationValueConfigurator {
  func getConfigurationValue(forKey key: String, completion: @escaping (String) -> Void) {
    if let value = secureDataManagerService.getString(for: key) {
      completion(value)
    }
    
    cloudKitService.getConfigurationValue(from: key) { (value: String?) in
      if let value {
        completion(value)
        secureDataManagerService.saveString(value, key: key)
      }
    }
  }
}

// MARK: - Private

private enum Constants {
  static let infuraKey = "infura_keys"
  static let tokenBaseUrlKey = "token_base_url"
  static let oneInchKeys = "one_inch_keys"
}
