// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SKManagers",
  defaultLocalization: "en",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "SKManagers",
      targets: ["SKManagers"]
    ),
  ],
  dependencies: [
    .package(path: "../../LocalDependencies/SKServices")
  ],
  targets: [
    .target(
      name: "SKManagers",
      dependencies: [
        "SKServices"
      ]
    )
  ]
)
