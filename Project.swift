import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Setup project

let project = Project(
  name: "\(Constants.appNameRelease)",
  organizationName: Constants.organizationName,
  options: .options(automaticSchemesOptions: .disabled),
  settings: .app,
  targets: .app,
  schemes: [Scheme.app],
  resourceSynthesizers: [
    .assets(),
    .strings()
  ]
)
