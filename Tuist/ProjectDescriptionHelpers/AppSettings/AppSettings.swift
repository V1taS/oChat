//
//  AppSettings.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 04.03.2024.
//

import ProjectDescription

enum AppSettings {
  static func make(
    for configuration: ConfigurationName,
    isAppSettings: Bool
  ) -> SettingsDictionary {
    
    var settings: SettingsDictionary = [
      "PRODUCT_BUNDLE_IDENTIFIER": configuration.bundleIdentifier.settingsValue,
      "IPHONEOS_DEPLOYMENT_TARGET": "\(Constants.iOSTargetVersion)",
      "DEVELOPMENT_TEAM": "\(Constants.developmentTeam)",
      "CODE_SIGN_STYLE": "Automatic",
      "SDKROOT": "iphoneos",
      "TARGETED_DEVICE_FAMILY": "1",
      "ENABLE_TARGET_PARALLELIZATION": "YES"
    ]
    
    if isAppSettings {
      settings["SWIFT_COMPILATION_MODE"] = configuration.compilationMode.settingsValue
      settings["SWIFT_OPTIMIZATION_LEVEL"] = configuration.optimizationLevel.settingsValue
      settings["DEBUG_INFORMATION_FORMAT"] = DebugInformationFormat.dwarfWithDsym.rawValue.settingsValue
    }
    return settings
  }
}
