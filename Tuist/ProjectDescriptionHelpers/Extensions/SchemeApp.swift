//
//  SchemeApp.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 04.03.2024.
//

import ProjectDescription

public extension Scheme {
  static var app: Scheme {
    Scheme(
      name: Constants.appNameRelease,
      shared: true,
      buildAction: .buildAction(targets: ["\(Constants.appNameRelease)"]),
      testAction: .targets(["\(Constants.appNameRelease)Tests"]),
      runAction: .runAction(
        configuration: .debug,
        executable: "\(Constants.appNameRelease)",
        arguments: .init(environmentVariables: [
          "OS_ACTIVITY_MODE": .init(value: "disable", isEnabled: true)
        ])
      ),
      archiveAction: .archiveAction(
        configuration: .release
      )
    )
  }
}
