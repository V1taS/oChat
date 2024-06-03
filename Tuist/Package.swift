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
    .package(url: "https://github.com/airbnb/lottie-ios.git", exact: "4.3.4"),
    
    .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket", exact: "7.6.5"),
    
    .package(path: "../../../LocalDependencies/SKMySecret"),
    .package(path: "../../../LocalDependencies/Ecies"),
    .package(path: "../../../LocalDependencies/SwiftTor"),
    .package(path: "../../../LocalDependencies/SwiftUICharts")
  ]
)
