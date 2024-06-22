// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Wormholy",
  defaultLocalization: "en",
  platforms: [.iOS(.v13)],
  products: [
    .library(
      name: "Wormholy",
      targets: ["Wormholy"]
    ),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Wormholy",
      dependencies: [],
      resources: [
//        .copy("UI/Cells/ActionableTableViewCell.xib"),
//        .copy("UI/Flow.storyboard"),
//        .copy("UI/Cells/RequestCell.xib"),
//        .copy("UI/Sections/RequestTitleSectionView.xib"),
//        .copy("UI/Cells/TextTableViewCell.xib"),
//        .copy("UI/Flow.storyboard")
      ]
    )
  ]
)
