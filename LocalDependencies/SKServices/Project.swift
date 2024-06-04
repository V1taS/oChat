//
//  Project.swift
//  SKServices
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = ModuleProject.makeProject(
  name: "SKServices",
  dependencies: [
    .project(target: "SKFoundation", path: .relativeToManifest("../SKFoundation")),
    .project(target: "SKNotifications", path: .relativeToManifest("../SKNotifications")),
    .project(target: "SKNetwork", path: .relativeToManifest("../SKNetwork")),
    .project(target: "SKStyle", path: .relativeToManifest("../SKStyle")),
    .external(name: "SKMySecret"),
    .external(name: "Ecies"),
    .external(name: "SwiftTor"),
    .external(name: "CocoaAsyncSocket"),
    .external(name: "SKAbstractions")
  ],
  settings: .common()
)
