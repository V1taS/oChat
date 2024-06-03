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
        animationName: OChatAsset.newWalletScreenPasscode.name,
        title: OChatStrings.SuggestScreenLocalization.State.AccessCode.title,
        description: OChatStrings.SuggestScreenLocalization.State.AccessCode.description,
        buttonTitle: OChatStrings.SuggestScreenLocalization.State.AccessCode.buttonTitle
      )
    case .setFaceID:
      return .init(
        animationName: OChatAsset.newWalletScreenFaceId.name,
        title: OChatStrings.SuggestScreenLocalization.State.FaceID.title,
        description: "",
        buttonTitle: OChatStrings.SuggestScreenLocalization.State.FaceID.buttonTitle
      )
    case .setNotifications:
      return .init(
        animationName: OChatAsset.newWalletEnableNotifications.name,
        title: OChatStrings.SuggestScreenLocalization.State.Notifications.title,
        description: OChatStrings.SuggestScreenLocalization.State.Notifications.description,
        buttonTitle: OChatStrings.SuggestScreenLocalization.State.Notifications.buttonTitle
      )
    }
  }
}

// MARK: - Private

private extension SuggestScreenFactory {}

// MARK: - Constants

private enum Constants {}
