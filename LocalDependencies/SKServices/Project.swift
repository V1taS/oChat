//
//  Project.swift
//  SKServices
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = ModuleProject.makeProject(
  name: "SKServices",
  dependencies: [
    .project(target: "SKAbstractions", path: .relativeToManifest("../SKAbstractions")),
    .project(target: "SKFoundation", path: .relativeToManifest("../SKFoundation")),
    .project(target: "SKNotifications", path: .relativeToManifest("../SKNotifications")),
    .project(target: "SKNetwork", path: .relativeToManifest("../SKNetwork")),
    .project(target: "SKStyle", path: .relativeToManifest("../SKStyle")),
    .external(name: "SKMySecret"),
    
    // Blockchain
    .xcframework(
      path: .relativeToManifest("../Blockchain/WalletCore.xcframework"),
      status: .required,
      condition: nil
    ),
    .xcframework(
      path: .relativeToManifest("../Blockchain/SwiftProtobuf.xcframework"),
      status: .required,
      condition: nil
    ),
    
    .external(name: "Ecies"),
    .external(name: "SwiftTor"),
    .external(name: "CocoaAsyncSocket")
//    .external(name: "web3.swift")
  ],
  settings: .common()
)
