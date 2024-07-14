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
    .package(path: "../../../LocalDependencies/MessengerSDK"),
    .package(path: "../../../LocalDependencies/AuthenticationSDK"),
    .package(path: "../../../LocalDependencies/SKStoriesWidget"),
    .package(path: "../../../LocalDependencies/SKUIKit"),
    .package(path: "../../../LocalDependencies/SKServices"),
    .package(path: "../../../LocalDependencies/ExyteChat"),
    .package(path: "../../../LocalDependencies/ExyteMediaPicker")
  ]
)
