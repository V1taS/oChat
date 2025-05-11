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
    .package(path: "../LocalDependencies/ToxSwift")
  ]
)

extension Package: @unchecked Sendable {}
