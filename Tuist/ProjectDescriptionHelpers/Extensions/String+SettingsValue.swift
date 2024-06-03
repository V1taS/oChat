//
//  String+SettingsValue.swift
//  ProjectDescriptionHelpers
//
//  Created by Vitalii Sosin on 04.03.2024.
//

import ProjectDescription

public extension String {
  var settingsValue: SettingValue {
    return SettingValue(stringLiteral: self)
  }
}
