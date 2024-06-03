//
//  ModuleProject.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 04.03.2024.
//

import ProjectDescription

public enum ModuleProject {
  public struct ExampleAppConfiguration {
    public var scripts: [TargetScript]
    public var resources: ResourceFileElements?
    public var additionalDependencies: [TargetDependency]
    
    public init(
      scripts: [TargetScript],
      resources: ResourceFileElements? = nil,
      additionalDependencies: [TargetDependency]
    ) {
      self.scripts = scripts
      self.resources = resources
      self.additionalDependencies = additionalDependencies
    }
  }
  
  public static func makeProject(
    name: String,
    product: Product = .framework,
    packages: [ProjectDescription.Package] = [],
    resources: ResourceFileElements? = nil,
    scripts: [TargetScript] = [],
    dependencies: [TargetDependency] = [],
    resourceSynthesizers: [ResourceSynthesizer] = [],
    settings: Settings = .common(),
    generateExampleAppTarget: Bool = false,
    exampleConfiguration: ExampleAppConfiguration? = nil,
    headers: Headers? = nil
  ) -> Project {
    var targets: [Target] = [
      .module(
        name: name,
        product: product,
        resources: resources,
        scripts: scripts,
        dependencies: dependencies,
        launchArguments: [],
        headers: headers
      )
    ]
    
    if generateExampleAppTarget {
      var resources: ResourceFileElements? = nil
      var scripts: [TargetScript] = []
      var dependencies: [TargetDependency] = [
        .target(name: name)
      ]
      
      if let config = exampleConfiguration {
        resources = config.resources
        scripts = config.scripts
        dependencies.append(contentsOf: config.additionalDependencies)
      }
      
      let appTarget = Target(
        name: name.appending("App"),
        destinations: .iOS,
        product: .app,
        bundleId: "\(Constants.bundleIdentifier(name: "example"))",
        deploymentTargets: .defaultDeploymentTargets,
        infoPlist: InfoPlist.app,
        sources: [
          "Example/**"
        ],
        resources: resources,
        scripts: scripts + [],
        dependencies: dependencies,
        settings: .exampleApp
      )
      targets.append(appTarget)
    }
    
    let project = Project(
      name: name,
      options: .options(developmentRegion: "\(Constants.developmentRegion)"),
      packages: packages,
      settings: settings,
      targets: targets,
      resourceSynthesizers: resourceSynthesizers
    )
    return project
  }
}

public extension Target {
  static func module(
    name: String,
    product: Product = .framework,
    resources: ResourceFileElements? = nil,
    scripts: [TargetScript],
    dependencies: [TargetDependency],
    launchArguments: [LaunchArgument] = [],
    headers: Headers? = nil
  ) -> Target {
    return Target(
      name: name,
      destinations: .iOS,
      product: product,
      bundleId: Constants.bundleIdentifier(name: name),
      deploymentTargets: .defaultDeploymentTargets,
      sources: ["Sources/**"],
      resources: resources,
      headers: headers,
      scripts: scripts,
      dependencies: dependencies,
      launchArguments: launchArguments,
      additionalFiles: []
    )
  }
}
