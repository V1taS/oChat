// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SKServices",
  defaultLocalization: "en",
  platforms: [.iOS(.v16)],
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
    .package(path: "../../LocalDependencies/Ecies"),
    .package(path: "../../LocalDependencies/ToxCore"),
    .package(path: "../../LocalDependencies/Wormholy"),
    .package(url: "https://github.com/marmelroy/Zip.git", exact: "2.1.2"),
  ],
  targets: [
    .target(
      name: "SKServices",
      dependencies: [
        "SKStyle",
        "SKMySecret",
        "Ecies",
        "SKNetwork",
        "SKAbstractions",
        "SKFoundation",
        "SKNotifications",
        "ToxCore",
        "Wormholy",
        "Zip"
      ]
    )
  ]
)
