//
//  ExyteChatStrings.swift
//  ExyteChat
//
//  Created by Vitalii Sosin on 13.07.2024.
//

import Foundation

public enum ExyteChatStrings {
  public static let attachmentsEditorButtonCancelTitle = ExyteChatStrings.tr(
    "Localization",
    "AttachmentsEditor.Button.Cancel.Title"
  )
  public static let attachmentsEditorButtonRecentsTitle = ExyteChatStrings.tr(
    "Localization",
    "AttachmentsEditor.Button.Recents.Title"
  )
}

// MARK: - Implementation Details

extension ExyteChatStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = ExyteChatResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
