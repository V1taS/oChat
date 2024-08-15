// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ExyteChat",
  platforms: [
    .iOS(.v16)
  ],
  products: [
    .library(
      name: "ExyteChat",
      targets: ["ExyteChat"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/siteline/swiftui-introspect",
      from: "1.0.0"
    ),
    .package(path: "../../LocalDependencies/ExyteMediaPicker"),
    .package(
      url: "https://github.com/exyte/FloatingButton",
      from: "1.2.2"
    ),
    .package(
      url: "https://github.com/exyte/ActivityIndicatorView",
      from: "1.0.0"
    ),
    .package(path: "../../LocalDependencies/SKAbstractions"),
    .package(path: "../../LocalDependencies/SKFoundation"),
    .package(path: "../../LocalDependencies/SKStyle")
  ],
  targets: [
    .target(
      name: "ExyteChat",
      dependencies: [
        .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
        .product(name: "FloatingButton", package: "FloatingButton"),
        .product(name: "ActivityIndicatorView", package: "ActivityIndicatorView"),
        "SKAbstractions",
        "SKFoundation",
        "SKStyle",
        "ExyteMediaPicker"
      ]
    ),
    .testTarget(
      name: "ExyteChatTests",
      dependencies: ["ExyteChat"]
    ),
  ]
)
