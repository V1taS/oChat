// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SKMySecret",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "SKMySecret",
      targets: ["SKMySecret"]
    ),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "SKMySecret",
      dependencies: [],
      path: "Sources/SKMySecret"
    ),
    .testTarget(
      name: "MySecretTests",
      dependencies: ["SKMySecret"]
    )
  ]
)
