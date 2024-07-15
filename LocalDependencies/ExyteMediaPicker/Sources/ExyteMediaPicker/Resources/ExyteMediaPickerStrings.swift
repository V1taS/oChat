//
//  ExyteMediaPickerStrings.swift
//  ExyteMediaPicker
//
//  Created by Vitalii Sosin on 15.07.2024.
//

import Foundation

public enum ExyteMediaPickerStrings {
  public static let cameraButtonCancelTitle = ExyteMediaPickerStrings.tr(
    "Localization",
    "Camera.Button.Cancel.Title"
  )
  public static let cameraButtonDoneTitle = ExyteMediaPickerStrings.tr(
    "Localization",
    "Camera.Button.Done.Title"
  )
  public static let cameraButtonVideoTitle = ExyteMediaPickerStrings.tr(
    "Localization",
    "Camera.Button.Video.Title"
  )
  public static let cameraButtonPhotoTitle = ExyteMediaPickerStrings.tr(
    "Localization",
    "Camera.Button.Photo.Title"
  )
}

// MARK: - Implementation Details

extension ExyteMediaPickerStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = ExyteMediaPickerResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
