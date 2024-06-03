//
//  SettingsApp.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 04.03.2024.
//

import ProjectDescription

public extension Settings {
  static var app: Settings {
    Settings.settings(
      configurations: Configuration.defaults(with: [.settings, .xcconfig, .app])
    )
  }
  
  static var exampleApp: Settings {
    Settings.settings(
      base: [
        "PRODUCT_BUNDLE_IDENTIFIER": "\(Constants.bundleApp).example",
      ],
      configurations: [
        .debug(name: .debug)
      ]
    )
  }
  
  static func common(extendBase: SettingsDictionary = [:]) -> Settings {
    var defaultBase = [
      "PRODUCT_BUNDLE_IDENTIFIER": Constants.bundleApp.settingsValue,
      "IPHONEOS_DEPLOYMENT_TARGET": Constants.iOSTargetVersion.settingsValue
    ]
    
    if !extendBase.isEmpty {
      defaultBase.merge(extendBase)
    }
    
    return Settings.settings(
      base: defaultBase,
      configurations: Configuration.defaults(with: .none)
    )
  }
}
