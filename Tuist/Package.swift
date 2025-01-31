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
    .package(path: "../LocalDependencies/SKStoriesWidget"),
    .package(path: "../LocalDependencies/SKUIKit"),
    .package(path: "../LocalDependencies/SKManagers"),
    .package(path: "../LocalDependencies/SKServices"),
    .package(path: "../LocalDependencies/SKChat")
  ]
)
