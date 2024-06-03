//
//  BuildScripts.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 04.03.2024.
//

import Foundation
import ProjectDescription

public extension TargetScript {
  static func swiftlint(configPath: String) -> Self {
    .pre(
      script: """
    if test -d "/opt/homebrew/bin/"; then
      PATH="/opt/homebrew/bin/:${PATH}"
    fi
    
    export PATH="$PATH:/opt/homebrew/bin"
    
    if which swiftlint > /dev/null; then
      swiftlint "${SRCROOT}/\(configPath)"
    else
      echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    fi
    """,
      name: "SwiftLintString",
      basedOnDependencyAnalysis: false
    )
  }
}
