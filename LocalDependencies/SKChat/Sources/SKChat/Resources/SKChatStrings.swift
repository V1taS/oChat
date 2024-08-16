//
//  SKChatStrings.swift
//  ExyteChat
//
//  Created by Vitalii Sosin on 13.07.2024.
//

import Foundation

public enum SKChatStrings {
  public static let attachmentsEditorButtonCancelTitle = SKChatStrings.tr(
    "Localization",
    "AttachmentsEditor.Button.Cancel.Title"
  )
  public static let attachmentsEditorButtonRecentsTitle = SKChatStrings.tr(
    "Localization",
    "AttachmentsEditor.Button.Recents.Title"
  )
  public static let galleryHeaderImageTitle = SKChatStrings.tr(
    "Localization",
    "GalleryHeader.Image.Title"
  )
  public static let galleryHeaderVideoTitle = SKChatStrings.tr(
    "Localization",
    "GalleryHeader.Video.Title"
  )
  public static let gridPhotosHeaderTitle = SKChatStrings.tr(
    "Localization",
    "GridPhotos.Header.Title"
  )
  public static let messageMenuReplyTitle = SKChatStrings.tr(
    "Localization",
    "MessageMenu.Reply.Title"
  )
  public static let messageMenuCopyTitle = SKChatStrings.tr(
    "Localization",
    "MessageMenu.Copy.Title"
  )
  public static let messageMenuDeleteTitle = SKChatStrings.tr(
    "Localization",
    "MessageMenu.Delete.Title"
  )
  public static let messageMenuRetryTitle = SKChatStrings.tr(
    "Localization",
    "MessageMenu.Retry.Title"
  )
  public static let inputReplyTitle = SKChatStrings.tr(
    "Localization",
    "Input.Reply.Title"
  )
  public static let inputRecordingTitle = SKChatStrings.tr(
    "Localization",
    "Input.Recording.Title"
  )
  public static let inputCancelTitle = SKChatStrings.tr(
    "Localization",
    "Input.Cancel.Title"
  )
  public static let cameraButtonCancelTitle = SKChatStrings.tr(
    "Localization",
    "Camera.Button.Cancel.Title"
  )
  public static let cameraButtonDoneTitle = SKChatStrings.tr(
    "Localization",
    "Camera.Button.Done.Title"
  )
  public static let cameraButtonVideoTitle = SKChatStrings.tr(
    "Localization",
    "Camera.Button.Video.Title"
  )
  public static let cameraButtonPhotoTitle = SKChatStrings.tr(
    "Localization",
    "Camera.Button.Photo.Title"
  )
}

// MARK: - Implementation Details

extension SKChatStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = SKChatResources.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
