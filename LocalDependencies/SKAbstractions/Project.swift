//
//  Project.swift
//  SKAbstractions
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = ModuleProject.makeProject(
  name: "SKAbstractions",
  resources: [
    "Sources/Resources/**",
    "Sources/**/*.lproj/**"
  ],
  resourceSynthesizers: [
    .assets(),
    .strings()
  ],
  settings: .common()
)
