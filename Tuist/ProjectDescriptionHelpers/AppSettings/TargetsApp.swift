//
//  TargetsApp.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 04.03.2024.
//

import ProjectDescription

public extension Array<Target> {
  static var app: Self {
    [
      .target(
        name: Constants.appNameRelease,
        destinations: .iOS,
        product: .app,
        bundleId: "\(Constants.bundleApp)",
        deploymentTargets: .defaultDeploymentTargets,
        infoPlist: InfoPlist.app,
        sources: [
          "\(Constants.rootPath)/\(Constants.appPath)/Sources/**/*",
        ],
        resources: [
          "\(Constants.rootPath)/\(Constants.appPath)/Resources/**/*",
          "\(Constants.rootPath)/\(Constants.appPath)/Sources/**/*.strings",
          "\(Constants.rootPath)/\(Constants.appPath)/Sources/**/*.stringsdict"
        ],
        entitlements: .file(path: .relativeToRoot("\(Constants.rootPath)/\(Constants.appPath)/Entity/\(Constants.appNameRelease).entitlements")),
        scripts: [
          .swiftlint(configPath: "\(Constants.appNameRelease)/\(Constants.appPath)/Sources"),
        ],
        dependencies: [
          .external(name: "ToxSwift"),
          .external(name: "Ecies"),
          .external(name: "SKNotifications"),
          .external(name: "ZipArchive"),
          .external(name: "ApphudSDK"),
          .external(name: "AmplitudeSwift")
        ],
        settings: Settings.app
      ),
      // TODO: - Тесты пока не пишем
//      Target(
//        name: "\(Constants.appNameRelease)Tests",
//        destinations: .iOS,
//        product: .unitTests,
//        bundleId: "\(Constants.bundleApp)",
//        deploymentTargets: .defaultDeploymentTargets,
//        sources: ["\(Constants.rootPath)/\(Constants.appPath)\(Constants.appNameRelease)Tests/**"],
//        dependencies: [
//          .target(name: "\(Constants.appNameRelease)")
//        ]
//      ),
//      Target(
//        name: "\(Constants.appNameRelease)UITests",
//        destinations: .iOS,
//        product: .uiTests,
//        bundleId: "\(Constants.bundleApp)",
//        deploymentTargets: .defaultDeploymentTargets,
//        sources: ["\(Constants.rootPath)/\(Constants.appPath)\(Constants.appNameRelease)UITests/**"],
//        dependencies: [
//          .target(name: "\(Constants.appNameRelease)")
//        ],
//        settings: Settings.app
//      )
    ]
  }
}
