// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AuthenticationSDK",
  defaultLocalization: "en",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "AuthenticationSDK",
      targets: ["AuthenticationSDK"]
    ),
  ],
  dependencies: [
    .package(path: "../../LocalDependencies/SKUIKit"),
    .package(path: "../../LocalDependencies/SKFoundation"),
    .package(path: "../../LocalDependencies/SKAbstractions")
  ],
  targets: [
    .target(
      name: "AuthenticationSDK",
      dependencies: [
        "SKUIKit",
        "SKFoundation",
        "SKAbstractions"
      ]
    )
  ]
)
