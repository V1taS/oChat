//
//  Project.swift
//  SKUIKit
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = ModuleProject.makeProject(
  name: "SKUIKit",
  resources: [
    "Sources/Resources/**",
    "Sources/**/*.lproj/**"
  ],
  dependencies: [
    .project(target: "SKStyle", path: .relativeToManifest("../SKStyle")),
    .project(target: "SKFoundation", path: .relativeToManifest("../SKFoundation")),
    .external(name: "Lottie"),
    .external(name: "SwiftUICharts"),
    .external(name: "SKAbstractions")
  ],
  resourceSynthesizers: [
    .assets(),
    .strings()
  ],
  settings: .common()
)
