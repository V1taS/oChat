// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ToxCore",
  products: [
    .library(
      name: "ToxCore",
      targets: ["ToxCore"]
    ),
  ],
  targets: [
    .target(
      name: "ToxCore",
      dependencies: [
        "ToxCoreCpp"
      ]
    ),
    .target(
      name: "ToxCoreCpp",
      dependencies: [],
      publicHeadersPath: "Headers",
      cSettings: [
        .headerSearchPath("Headers"),
        .define("SOME_PREPROCESSOR_DEFINITION"),
      ],
      cxxSettings: [
        .define("CPP_SPECIFIC_DEFINE"),
        .headerSearchPath("Headers"),
        .unsafeFlags(["-std=c++11"], .when(platforms: [.iOS]))
      ]
    )
  ]
)
