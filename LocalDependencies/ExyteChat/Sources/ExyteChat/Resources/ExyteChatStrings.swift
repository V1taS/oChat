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
  
  public static let galleryHeaderImageTitle = ExyteChatStrings.tr(
    "Localization",
    "GalleryHeader.Image.Title"
  )
  public static let galleryHeaderVideoTitle = ExyteChatStrings.tr(
    "Localization",
    "GalleryHeader.Video.Title"
  )
  public static let gridPhotosHeaderTitle = ExyteChatStrings.tr(
    "Localization",
    "GridPhotos.Header.Title"
  )
  public static let messageMenuReplyTitle = ExyteChatStrings.tr(
    "Localization",
    "MessageMenu.Reply.Title"
  )
  public static let messageMenuCopyTitle = ExyteChatStrings.tr(
    "Localization",
    "MessageMenu.Copy.Title"
  )
  public static let messageMenuDeleteTitle = ExyteChatStrings.tr(
    "Localization",
    "MessageMenu.Delete.Title"
  )
  public static let messageMenuRetryTitle = ExyteChatStrings.tr(
    "Localization",
    "MessageMenu.Retry.Title"
  )
}

// MARK: - Implementation Details

extension ExyteChatStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = ExyteChatResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
