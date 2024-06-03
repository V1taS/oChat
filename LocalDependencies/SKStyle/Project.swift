//
//  Project.swift
//  SKStyle
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = ModuleProject.makeProject(
  name: "SKStyle",
  resources: [
    "Sources/Resources/**",
  ],
  resourceSynthesizers: [
    .assets()
  ],
  settings: .common()
)
