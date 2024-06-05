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
   .package(url: "https://github.com/V1taS/MessengerSDK", exact: "1.3.0"),
   .package(url: "https://github.com/V1taS/AuthenticationSDK", exact: "1.3.0"),
   .package(url: "https://github.com/V1taS/SKStoriesWidget", exact: "1.0.0"),
   .package(url: "https://github.com/V1taS/SKUIKit", exact: "1.2.0"),
   .package(url: "https://github.com/V1taS/Wormholy", exact: "1.0.0"),
   .package(url: "https://github.com/V1taS/SKServices", exact: "1.8.0")
    
    // .package(path: "../../../../General/SKAbstractions"),
    // .package(path: "../../../../General/MessengerSDK"),
    // .package(path: "../../../../General/SKServices"),
    // .package(path: "../../../../General/SKUIKit")
  ]
)
