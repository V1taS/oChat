//
//  HintBackupScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol HintBackupScreenFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol HintBackupScreenFactoryInput {
  /// Создать модель данных
  func createModel(
    _ hintType: HintBackupScreenType
  ) -> HintBackupScreenModel
}

/// Фабрика
final class HintBackupScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: HintBackupScreenFactoryOutput?
}

// MARK: - HintBackupScreenFactoryInput

extension HintBackupScreenFactory: HintBackupScreenFactoryInput {
  func createModel(_ hintType: HintBackupScreenType) -> HintBackupScreenModel {
    switch hintType {
    case .backupPhrase:
      return createBackupPhraseModel()
    case .backupImage:
      return createBackupImageModel()
    case .messenger:
      return createHintMessengerModel()
    }
  }
}

// MARK: - Private

private extension HintBackupScreenFactory {
  func createHintMessengerModel() -> HintBackupScreenModel {
    return HintBackupScreenModel(
      lottieAnimationName: nil,
      headerTitle: oChatStrings.HintBackupScreenLocalization.Messenger.Header.title,
      headerDescription: oChatStrings.HintBackupScreenLocalization.Messenger.Header.description,
      buttonTitle: oChatStrings.HintBackupScreenLocalization.Messenger.Button.title,
      oneTitle: oChatStrings.HintBackupScreenLocalization.Messenger.One.title,
      oneDescription: oChatStrings.HintBackupScreenLocalization.Messenger.One.description,
      oneSystemImageName: "paperplane.fill",
      twoTitle: oChatStrings.HintBackupScreenLocalization.Messenger.Two.title,
      twoDescription: oChatStrings.HintBackupScreenLocalization.Messenger.Two.description,
      twoSystemImageName: "centsign.circle",
      threeTitle: oChatStrings.HintBackupScreenLocalization.Messenger.Three.title,
      threeDescription: oChatStrings.HintBackupScreenLocalization.Messenger.Three.description,
      threeSystemImageName: "lock.shield"
    )
  }
  
  func createBackupPhraseModel() -> HintBackupScreenModel {
    return HintBackupScreenModel(
      lottieAnimationName: nil,
      headerTitle: oChatStrings.HintBackupScreenLocalization.BackupPhrase.Header.title,
      headerDescription: oChatStrings.HintBackupScreenLocalization.BackupPhrase.Header.description,
      buttonTitle: oChatStrings.HintBackupScreenLocalization.BackupPhrase.Button.title,
      oneTitle: oChatStrings.HintBackupScreenLocalization.BackupPhrase.One.title,
      oneDescription: oChatStrings.HintBackupScreenLocalization.BackupPhrase.One.description,
      oneSystemImageName: "doc.text",
      twoTitle: oChatStrings.HintBackupScreenLocalization.BackupPhrase.Two.title,
      twoDescription: oChatStrings.HintBackupScreenLocalization.BackupPhrase.Two.description,
      twoSystemImageName: "exclamationmark.arrow.circlepath",
      threeTitle: oChatStrings.HintBackupScreenLocalization.BackupPhrase.Three.title,
      threeDescription: oChatStrings.HintBackupScreenLocalization.BackupPhrase.Three.description,
      threeSystemImageName: "key"
    )
  }
  
  func createBackupImageModel() -> HintBackupScreenModel {
    return HintBackupScreenModel(
      lottieAnimationName: nil,
      headerTitle: oChatStrings.HintBackupScreenLocalization.BackupImage.Header.title,
      headerDescription: oChatStrings.HintBackupScreenLocalization.BackupImage.Header.description,
      buttonTitle: oChatStrings.HintBackupScreenLocalization.BackupImage.Button.title,
      oneTitle: oChatStrings.HintBackupScreenLocalization.BackupImage.One.title,
      oneDescription: oChatStrings.HintBackupScreenLocalization.BackupImage.One.description,
      oneSystemImageName: "photo",
      twoTitle: oChatStrings.HintBackupScreenLocalization.BackupImage.Two.title,
      twoDescription: oChatStrings.HintBackupScreenLocalization.BackupImage.Two.description,
      twoSystemImageName: "exclamationmark.triangle",
      threeTitle: oChatStrings.HintBackupScreenLocalization.BackupImage.Three.title,
      threeDescription: oChatStrings.HintBackupScreenLocalization.BackupImage.Three.description,
      threeSystemImageName: "lock.shield"
    )
  }
}

// MARK: - Constants

private enum Constants {}
