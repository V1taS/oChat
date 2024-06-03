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
      headerTitle: OChatStrings.HintBackupScreenLocalization.Messenger.Header.title,
      headerDescription: OChatStrings.HintBackupScreenLocalization.Messenger.Header.description,
      buttonTitle: OChatStrings.HintBackupScreenLocalization.Messenger.Button.title,
      oneTitle: OChatStrings.HintBackupScreenLocalization.Messenger.One.title,
      oneDescription: OChatStrings.HintBackupScreenLocalization.Messenger.One.description,
      oneSystemImageName: "paperplane.fill",
      twoTitle: OChatStrings.HintBackupScreenLocalization.Messenger.Two.title,
      twoDescription: OChatStrings.HintBackupScreenLocalization.Messenger.Two.description,
      twoSystemImageName: "centsign.circle",
      threeTitle: OChatStrings.HintBackupScreenLocalization.Messenger.Three.title,
      threeDescription: OChatStrings.HintBackupScreenLocalization.Messenger.Three.description,
      threeSystemImageName: "lock.shield"
    )
  }
  
  func createBackupPhraseModel() -> HintBackupScreenModel {
    return HintBackupScreenModel(
      lottieAnimationName: nil,
      headerTitle: OChatStrings.HintBackupScreenLocalization.BackupPhrase.Header.title,
      headerDescription: OChatStrings.HintBackupScreenLocalization.BackupPhrase.Header.description,
      buttonTitle: OChatStrings.HintBackupScreenLocalization.BackupPhrase.Button.title,
      oneTitle: OChatStrings.HintBackupScreenLocalization.BackupPhrase.One.title,
      oneDescription: OChatStrings.HintBackupScreenLocalization.BackupPhrase.One.description,
      oneSystemImageName: "doc.text",
      twoTitle: OChatStrings.HintBackupScreenLocalization.BackupPhrase.Two.title,
      twoDescription: OChatStrings.HintBackupScreenLocalization.BackupPhrase.Two.description,
      twoSystemImageName: "exclamationmark.arrow.circlepath",
      threeTitle: OChatStrings.HintBackupScreenLocalization.BackupPhrase.Three.title,
      threeDescription: OChatStrings.HintBackupScreenLocalization.BackupPhrase.Three.description,
      threeSystemImageName: "key"
    )
  }
  
  func createBackupImageModel() -> HintBackupScreenModel {
    return HintBackupScreenModel(
      lottieAnimationName: nil,
      headerTitle: OChatStrings.HintBackupScreenLocalization.BackupImage.Header.title,
      headerDescription: OChatStrings.HintBackupScreenLocalization.BackupImage.Header.description,
      buttonTitle: OChatStrings.HintBackupScreenLocalization.BackupImage.Button.title,
      oneTitle: OChatStrings.HintBackupScreenLocalization.BackupImage.One.title,
      oneDescription: OChatStrings.HintBackupScreenLocalization.BackupImage.One.description,
      oneSystemImageName: "photo",
      twoTitle: OChatStrings.HintBackupScreenLocalization.BackupImage.Two.title,
      twoDescription: OChatStrings.HintBackupScreenLocalization.BackupImage.Two.description,
      twoSystemImageName: "exclamationmark.triangle",
      threeTitle: OChatStrings.HintBackupScreenLocalization.BackupImage.Three.title,
      threeDescription: OChatStrings.HintBackupScreenLocalization.BackupImage.Three.description,
      threeSystemImageName: "lock.shield"
    )
  }
}

// MARK: - Constants

private enum Constants {}
