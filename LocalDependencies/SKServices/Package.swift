// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SKServices",
  defaultLocalization: "en",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "SKServices",
      targets: ["SKServices"]
    ),
  ],
  dependencies: [
    .package(path: "../../LocalDependencies/SKStyle"),
    .package(path: "../../LocalDependencies/SKMySecret"),
    .package(path: "../../LocalDependencies/SKNetwork"),
    .package(path: "../../LocalDependencies/SKAbstractions"),
    .package(path: "../../LocalDependencies/SKFoundation"),
    .package(path: "../../LocalDependencies/SKNotifications"),
    .package(path: "../../LocalDependencies/SwiftTor"),
    .package(path: "../../LocalDependencies/CocoaAsyncSocket"),
    .package(path: "../../LocalDependencies/Ecies")
  ],
  targets: [
    .target(
      name: "SKServices",
      dependencies: [
        "SKStyle",
        "SKMySecret",
        "WalletCore",
        "SwiftProtobuf",
        "Ecies",
        "SKNetwork",
        "SKAbstractions",
        "SKFoundation",
        "SKNotifications",
        "SwiftTor",
        "CocoaAsyncSocket"
      ]
    ),
    .binaryTarget(name: "WalletCore", path: "Sources/XCFrameworks/WalletCore.xcframework"),
    .binaryTarget(name: "SwiftProtobuf", path: "Sources/XCFrameworks/SwiftProtobuf.xcframework")
  ]
)