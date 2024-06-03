//
//  Project.swift
//  SKStoriesWidget
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = ModuleProject.makeProject(
  name: "SKStoriesWidget",
  resources: [
    "Sources/Resources/**/*"
  ],
  settings: .common()
)
