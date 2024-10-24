// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SKChat",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "SKChat",
      targets: ["SKChat"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/siteline/swiftui-introspect",
      from: "1.0.0"
    ),
    .package(path: "../../LocalDependencies/SKAbstractions"),
    .package(path: "../../LocalDependencies/SKFoundation"),
    .package(path: "../../LocalDependencies/SKStyle")
  ],
  targets: [
    .target(
      name: "SKChat",
      dependencies: [
        .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
        "SKAbstractions",
        "SKFoundation",
        "SKStyle"
      ]
    ),
    .testTarget(
      name: "ExyteChatTests",
      dependencies: ["SKChat"]
    ),
  ]
)
