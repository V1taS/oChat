//
//  Project.swift
//  SKNotifications
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = ModuleProject.makeProject(
  name: "SKNotifications",
  resources: [
    "Sources/Resources/**/*"
  ],
  settings: .common()
)
