// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftTor",
  defaultLocalization: "en",
  platforms: [.iOS(.v13)],
  products: [
    .library(
      name: "SwiftTor",
      targets: ["SwiftTor"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "SwiftTor",
      dependencies: ["Tor"]
    ),
    .testTarget(
      name: "SwiftTorTests",
      dependencies: ["SwiftTor"]
    ),
    .binaryTarget(
      name: "Tor",
      path: "Sources/SwiftTor/Tor.xcframework"
    )
  ]
)
