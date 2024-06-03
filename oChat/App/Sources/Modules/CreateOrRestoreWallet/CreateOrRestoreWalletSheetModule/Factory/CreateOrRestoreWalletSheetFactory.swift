//
//  CreateOrRestoreWalletSheetFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol CreateOrRestoreWalletSheetFactoryOutput: AnyObject {
  /// Пользователь нажал создать Стандартный кошелек
  func createStandartSeedPhrase12WalletButtonTapped()
  /// Пользователь нажал создать Нерушимый кошелек
  func createIndestructibleSeedPhrase24WalletButtonTapped()
  /// Пользователь нажал создать Hi-Tech кошелек
  func createHighTechImageIDWalletButtonTapped()
  
  /// Пользователь нажал импорт кошелька
  func restoreWalletButtonTapped()
  /// Пользователь нажал импорт Hi-Tech кошелека
  func restoreHighTechImageIDWalletButtonTapped()
  /// Пользователь нажал импорт для отслеживания кошелек
  func restoreWalletForObserverButtonTapped()
}

/// Cобытия которые отправляем от Presenter к Factory
protocol CreateOrRestoreWalletSheetFactoryInput {
  /// Создать вью модель для отображения виджетов
  func createViewModel(
    with walletType: CreateOrRestoreWalletSheetType
  ) -> [CreateOrRestoreWalletSheetModel]
}

/// Фабрика
final class CreateOrRestoreWalletSheetFactory {
  
  // MARK: - Internal properties
  
  weak var output: CreateOrRestoreWalletSheetFactoryOutput?
}

// MARK: - CreateOrRestoreWalletSheetFactoryInput

extension CreateOrRestoreWalletSheetFactory: CreateOrRestoreWalletSheetFactoryInput {
  func createViewModel(
    with walletType: CreateOrRestoreWalletSheetType
  ) -> [CreateOrRestoreWalletSheetModel] {
    var models: [CreateOrRestoreWalletSheetModel] = []
    
    switch walletType {
    case .createWallet:
      models = createWalletModels()
    case .restoreWallet:
      models = restoreWalletModels()
    }
    return models
  }
}

// MARK: - Private

private extension CreateOrRestoreWalletSheetFactory {
  func createWalletModels() -> [CreateOrRestoreWalletSheetModel] {
    var models: [CreateOrRestoreWalletSheetModel] = []
    
    let seedPhrase12Model = CreateOrRestoreWalletSheetModel(
      image: Image(systemName: "12.circle"),
      title: oChatStrings.CreateOrRestoreWalletSheetLocalization.SeedPhrase12.title,
      description: oChatStrings.CreateOrRestoreWalletSheetLocalization.SeedPhrase12.description,
      action: { [weak self] in
        self?.output?.createStandartSeedPhrase12WalletButtonTapped()
      }
    )
    models.append(seedPhrase12Model)
    
    let seedPhrase24Model = CreateOrRestoreWalletSheetModel(
      image: Image(systemName: "24.circle"),
      title: oChatStrings.CreateOrRestoreWalletSheetLocalization.SeedPhrase24.title,
      description: oChatStrings.CreateOrRestoreWalletSheetLocalization.SeedPhrase24.description,
      action: { [weak self] in
        self?.output?.createIndestructibleSeedPhrase24WalletButtonTapped()
      }
    )
    models.append(seedPhrase24Model)
    
    let imageHighTechModel = CreateOrRestoreWalletSheetModel(
      image: Image(systemName: "photo.artframe.circle"),
      title: oChatStrings.CreateOrRestoreWalletSheetLocalization.ImageHighTech.title,
      description: oChatStrings.CreateOrRestoreWalletSheetLocalization.ImageHighTech.description,
      action: { [weak self] in
        self?.output?.createHighTechImageIDWalletButtonTapped()
      }
    )
    models.append(imageHighTechModel)
    
    return models
  }
  
  func restoreWalletModels() -> [CreateOrRestoreWalletSheetModel] {
    var models: [CreateOrRestoreWalletSheetModel] = []
    
    let importSeedPhraseModel = CreateOrRestoreWalletSheetModel(
      image: Image(systemName: "arrow.down.to.line.circle"),
      title: oChatStrings.CreateOrRestoreWalletSheetLocalization.ImportSeedPhrase.title,
      description: oChatStrings.CreateOrRestoreWalletSheetLocalization.ImportSeedPhrase.description,
      action: { [weak self] in
        self?.output?.restoreWalletButtonTapped()
      }
    )
    models.append(importSeedPhraseModel)
    
    let importImageHighTechModel = CreateOrRestoreWalletSheetModel(
      image: Image(systemName: "photo.artframe.circle"),
      title: oChatStrings.CreateOrRestoreWalletSheetLocalization.ImportImageHighTech.title,
      description: oChatStrings.CreateOrRestoreWalletSheetLocalization.ImportImageHighTech.description,
      action: { [weak self] in
        self?.output?.restoreHighTechImageIDWalletButtonTapped()
      }
    )
    models.append(importImageHighTechModel)
    
    // TODO: - Этот функционал добавлю позже
//    let trackWalletModel = CreateOrRestoreWalletSheetModel(
//      image: Image(systemName: "eye.circle"),
//      title: oChatStrings.CreateOrRestoreWalletSheetLocalization.TrackWallet.title,
//      description: oChatStrings.CreateOrRestoreWalletSheetLocalization.TrackWallet.description,
//      action: { [weak self] in
//        self?.output?.restoreWalletForObserverButtonTapped()
//      }
//    )
//    models.append(trackWalletModel)
    
    return models
  }
}

// MARK: - Constants

private enum Constants {}
