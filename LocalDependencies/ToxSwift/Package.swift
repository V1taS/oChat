// swift-tools-version:5.10
import PackageDescription
import Foundation

// ───────── local paths ───────────────────────────────────────────────────────
let vendorRoot = "Vendor"

// CSodium paths
let csodiumXC = "\(vendorRoot)/CSodium.xcframework"
let csodiumIOS = "\(csodiumXC)/ios-arm64/CSodium.framework/Headers"
let csodiumSim = "\(csodiumXC)/ios-arm64_i386_x86_64-simulator/CSodium.framework/Headers"

// libvpx paths
let vpxXC = "\(vendorRoot)/libvpx.xcframework"
let vpxIOS = "\(vpxXC)/ios-arm64/Headers"
let vpxSim = "\(vpxXC)/ios-arm64-simulator/Headers"

// ───────── manifest ──────────────────────────────────────────────────────────
let package = Package(
  name: "ToxSwift",
  platforms: [
    .iOS(.v17),
    .macOS(.v14)
  ],
  products: [
    .library(name: "ToxSwift", targets: ["ToxSwift"])
  ],
  dependencies: [],
  targets: [
    // Бинарные XCFramework'ы в ./Vendor
    .binaryTarget(name: "vpx", path: "\(vendorRoot)/libvpx.xcframework"),
    .binaryTarget(name: "CSodium", path: "\(vendorRoot)/CSodium.xcframework"),
    .binaryTarget(name: "ogg", path: "\(vendorRoot)/ogg.xcframework"),
    .binaryTarget(name: "opus", path: "\(vendorRoot)/opus.xcframework"),

    // C-обёртка toxcore
    .target(
      name: "CTox",
      dependencies: [
        "CSodium",
        "vpx",
        "ogg",
        "opus",
      ],
      publicHeadersPath: "Headers",
      cSettings: [
        .headerSearchPath("Headers"),
        .define("SOME_PREPROCESSOR_DEFINITION"),

        // sodium headers
        .headerSearchPath(csodiumIOS, .when(platforms: [.iOS])),
        .headerSearchPath(csodiumSim, .when(platforms: [.iOS])),
        .headerSearchPath(csodiumIOS, .when(platforms: [.macOS])),
        // libvpx headers
        .headerSearchPath(vpxIOS, .when(platforms: [.iOS])),
        .headerSearchPath(vpxSim, .when(platforms: [.iOS])),
        .headerSearchPath(vpxIOS, .when(platforms: [.macOS]))
      ],
      cxxSettings: [
        .define("CPP_SPECIFIC_DEFINE"),
        .headerSearchPath("Headers"),
        .unsafeFlags(["-std=c++11"], .when(platforms: [.iOS]))
      ]
    ),

    // Swift-обёртка
    .target(
      name: "ToxSwift",
      dependencies: ["CTox", "CSodium", "vpx"]
    )
  ]
)
