//
//  AppConfigurationName.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 04.03.2024.
//

import ProjectDescription

// MARK: - Configuration

extension Configuration {
  static func defaults(with options: Options) -> [Configuration] {
    [
      .debug(configuration: .debug, with: options),
      .release(configuration: .release, with: options)
    ]
  }
  
  static func debug(
    configuration: ConfigurationName,
    with options: Options
  ) -> Configuration {
    Configuration.debug(
      name: configuration,
      settings: options.contains(.settings) ? configuration.settings(isAppSettings: options.contains(.app)) : [:],
      xcconfig: .relativeToRoot("\(Constants.appNameRelease).xcconfig")
    )
  }
  
  static func release(
    configuration: ConfigurationName,
    with options: Options
  ) -> Configuration {
    Configuration.release(
      name: configuration,
      settings: options.contains(.settings) ? configuration.settings(isAppSettings: options.contains(.app)) : [:],
      xcconfig: .relativeToRoot("\(Constants.appNameRelease).xcconfig")
    )
  }
  
  struct Options: OptionSet {
    var rawValue: UInt8
    
    init(rawValue: UInt8) {
      self.rawValue = rawValue
    }
    
    static let settings = Options(rawValue: 1 << 0)
    static let xcconfig = Options(rawValue: 1 << 1)
    static let app = Options(rawValue: 1 << 2)
    
    static let none: Options = []
  }
}
