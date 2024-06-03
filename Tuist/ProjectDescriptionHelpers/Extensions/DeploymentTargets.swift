//
//  DeploymentTargets.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 04.03.2024.
//

import ProjectDescription

public extension DeploymentTargets {
  static let defaultDeploymentTargets: DeploymentTargets = DeploymentTargets(
    iOS: Constants.iOSTargetVersion,
    macOS: nil,
    watchOS: nil,
    tvOS: nil,
    visionOS: nil
  )
}
