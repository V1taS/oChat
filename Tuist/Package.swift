// swift-tools-version: 5.6
//
//  Package.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 04.03.2024.
//

import PackageDescription

let package = Package(
  name: "Package",
  dependencies: [
    .package(path: "../LocalDependencies/ToxSwift"),
    .package(path: "../LocalDependencies/Ecies"),
    .package(path: "../LocalDependencies/SKNotifications"),
    .package(path: "../LocalDependencies/ZipArchive"),
    .package(url: "https://github.com/amplitude/Amplitude-Swift", exact: "1.11.5"),
    .package(url: "https://github.com/apphud/ApphudSDK", exact: "3.6.2")
  ]
)

extension Package: @unchecked Sendable {}
