//
//  FirstLaunchConfigurator.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.07.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import SKUIKit
import UIKit
import SKStyle
import SwiftUI

struct FirstLaunchConfigurator: Configurator {
  
  // MARK: - Private properties
  
  private let services: IApplicationServices
  
  // MARK: - Init
  
  init(services: IApplicationServices) {
    self.services = services
  }
  
  // MARK: - Internal func
  
  func configure() {
    guard services.userInterfaceAndExperienceService.systemService.isFirstLaunch() else {
      return
    }
    clearDataOnFirstLaunch()
    setDarkColorScheme()
  }
}

// MARK: - Private

private extension FirstLaunchConfigurator {
  func clearDataOnFirstLaunch() {
    services.messengerService.modelHandlerService.deleteAllData()
  }
  
  func setDarkColorScheme() {
    services.userInterfaceAndExperienceService.uiService.saveColorScheme(.dark)
  }
}
