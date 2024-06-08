// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MessengerSDK",
  defaultLocalization: "en",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "MessengerSDK",
      targets: ["MessengerSDK"]
    ),
  ],
  dependencies: [
    .package(path: "../../LocalDependencies/SKUIKit"),
    .package(path: "../../LocalDependencies/SKFoundation"),
    .package(path: "../../LocalDependencies/SKAbstractions")
  ],
  targets: [
    .target(
      name: "MessengerSDK",
      dependencies: [
        "SKUIKit",
        "SKFoundation",
        "SKAbstractions"
      ]
    )
  ]
)
