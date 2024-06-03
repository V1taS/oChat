//
//  Project.swift
//  Wormholy
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = ModuleProject.makeProject(
  name: "Wormholy",
  resources: [
    "Sources/**/*.xib",
    "Sources/**/*.storyboard"
  ],
  dependencies: [],
  settings: .common()
)
