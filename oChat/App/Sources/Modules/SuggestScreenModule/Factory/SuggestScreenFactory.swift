//
//  SuggestScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol SuggestScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol SuggestScreenFactoryInput {
  /// Создать модельку с данными
  func createSuggestModel(_ state: SuggestScreenState) -> SuggestScreenModel
}

/// Фабрика
final class SuggestScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: SuggestScreenFactoryOutput?
}

// MARK: - SuggestScreenFactoryInput

extension SuggestScreenFactory: SuggestScreenFactoryInput {
  func createSuggestModel(_ state: SuggestScreenState) -> SuggestScreenModel {
    switch state {
    case .setAccessCode:
      return .init(
        animationName: oChatAsset.newWalletScreenPasscode.name,
        title: oChatStrings.SuggestScreenLocalization.State.AccessCode.title,
        description: oChatStrings.SuggestScreenLocalization.State.AccessCode.description,
        buttonTitle: oChatStrings.SuggestScreenLocalization.State.AccessCode.buttonTitle
      )
    case .setFaceID:
      return .init(
        animationName: oChatAsset.newWalletScreenFaceId.name,
        title: oChatStrings.SuggestScreenLocalization.State.FaceID.title,
        description: "",
        buttonTitle: oChatStrings.SuggestScreenLocalization.State.FaceID.buttonTitle
      )
    case .setNotifications:
      return .init(
        animationName: oChatAsset.newWalletEnableNotifications.name,
        title: oChatStrings.SuggestScreenLocalization.State.Notifications.title,
        description: oChatStrings.SuggestScreenLocalization.State.Notifications.description,
        buttonTitle: oChatStrings.SuggestScreenLocalization.State.Notifications.buttonTitle
      )
    }
  }
}

// MARK: - Private

private extension SuggestScreenFactory {}

// MARK: - Constants

private enum Constants {}
