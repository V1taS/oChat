//
//  ConfigurationName.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 04.03.2024.
//

import ProjectDescription

extension ConfigurationName {
  var appName: String {
    switch self {
    case .debug:
      return Constants.appNameDebug
    default:
      return Constants.appNameRelease
    }
  }
  
  var bundleIdentifier: String {
    switch self {
    case .release, .debug:
      return Constants.bundleApp
    default:
      fatalUnsupportedConfiguration()
    }
  }
  
  var optimizationLevel: String {
    switch self {
    case .release:
      return SwiftOptimizationLevel.o.rawValue
    default:
      return SwiftOptimizationLevel.oNone.rawValue
    }
  }
  
  var compilationMode: String {
    switch self {
    case .debug:
      return SwiftCompilationMode.singlefile.rawValue
    case .release:
      return SwiftCompilationMode.wholemodule.rawValue
    default:
      fatalUnsupportedConfiguration()
    }
  }
  
  func settings(isAppSettings: Bool) -> SettingsDictionary {
    return AppSettings.make(for: self, isAppSettings: isAppSettings)
  }
  
  @inline(__always)
  private func fatalUnsupportedConfiguration() -> Never {
    fatalError("Unsupported configuration name: \(self.rawValue)")
  }
}
