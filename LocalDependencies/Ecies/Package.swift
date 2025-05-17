// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Ecies",
  platforms: [.macOS(.v10_15), .iOS(.v13), .watchOS(.v8)],
  products: [
    .library(
      name: "Ecies",
      targets: ["Ecies"]
    ),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Ecies",
      dependencies: ["ASN1", "Digest"],
      path: "Sources/Ecies"
    ),
    .target(
      name: "BigInt",
      path: "Sources/BigInt"
    ),
    .target(
      name: "ASN1",
      dependencies: ["BigInt"],
      path: "Sources/ASN1"
    ),
    .target(
      name: "Digest",
      path: "Sources/Digest"
    )
  ]
)
