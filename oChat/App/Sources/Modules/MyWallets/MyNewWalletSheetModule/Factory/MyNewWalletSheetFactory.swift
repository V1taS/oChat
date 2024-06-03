//
//  MyNewWalletSheetFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKAbstractions
import SKUIKit

/// Cобытия которые отправляем из Factory в Presenter
protocol MyNewWalletSheetFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol MyNewWalletSheetFactoryInput {
  /// Создать модель для кошелька с сид фразой в 12 слова
  func createSeedPhrase12Model() -> MyNewWalletSheetModel
  
  /// Создать модель для кошелька с сид фразой в 24 слова
  func createSeedPhrase24Model() -> MyNewWalletSheetModel
  
  /// Создать модель для кошелька с Image ID
  func createImageHighTechModel() -> MyNewWalletSheetModel
  
  /// Создать модель для кошелька с сид фразой
  func createImportSeedPhraseWalletModel() -> MyNewWalletSheetModel
  
  /// Создать модель для кошелька с Image ID
  func createImportImageHighTechWalletModel() -> MyNewWalletSheetModel
  
  /// Возвращает заголовок для создания нового кошелька.
  /// - Returns: Строка, представляющая заголовок для создания нового кошелька.
  func getNewWalletHeaderTitle() -> String
  
  /// Возвращает заголовок для импорта кошелька.
  /// - Returns: Строка, представляющая заголовок для импорта кошелька.
  func getImportWalletHeaderTitle() -> String
  
  // TODO: - Добавлю позже этот функционал
  /// Создать модель для отслеживания кошелька
  //  func createTrackWalletModel() -> MyNewWalletSheetModel
}

/// Фабрика
final class MyNewWalletSheetFactory {
  
  // MARK: - Internal properties
  
  weak var output: MyNewWalletSheetFactoryOutput?
}

// MARK: - MyNewWalletSheetFactoryInput

extension MyNewWalletSheetFactory: MyNewWalletSheetFactoryInput {
  func getNewWalletHeaderTitle() -> String {
    OChatStrings.MyNewWalletSheetLocalization
      .State.NewWallet.header
  }
  
  func getImportWalletHeaderTitle() -> String {
    OChatStrings.MyNewWalletSheetLocalization
      .State.ImportWallet.header
  }
  
  func createSeedPhrase12Model() -> MyNewWalletSheetModel {
    MyNewWalletSheetModel(
      walletTitle: OChatStrings.MyNewWalletSheetLocalization
        .SeedPhrase12.title,
      walletDescription: OChatStrings.MyNewWalletSheetLocalization
        .SeedPhrase12.description,
      walletSystemImageName: "12.circle"
    )
  }
  
  func createSeedPhrase24Model() -> MyNewWalletSheetModel {
    MyNewWalletSheetModel(
      walletTitle: OChatStrings.MyNewWalletSheetLocalization
        .SeedPhrase24.title,
      walletDescription: OChatStrings.MyNewWalletSheetLocalization
        .SeedPhrase24.description,
      walletSystemImageName: "24.circle"
    )
  }
  
  func createImageHighTechModel() -> MyNewWalletSheetModel {
    MyNewWalletSheetModel(
      walletTitle: OChatStrings.MyNewWalletSheetLocalization
        .ImageHighTech.title,
      walletDescription: OChatStrings.MyNewWalletSheetLocalization
        .ImageHighTech.description,
      walletSystemImageName: "photo.artframe.circle"
    )
  }
  
  func createImportSeedPhraseWalletModel() -> MyNewWalletSheetModel {
    MyNewWalletSheetModel(
      walletTitle: OChatStrings.MyNewWalletSheetLocalization
        .ImportSeedPhrase.title,
      walletDescription: OChatStrings.MyNewWalletSheetLocalization
        .ImportSeedPhrase.description,
      walletSystemImageName: "arrow.down.to.line.circle"
    )
  }
  
  func createImportImageHighTechWalletModel() -> MyNewWalletSheetModel {
    MyNewWalletSheetModel(
      walletTitle: OChatStrings.MyNewWalletSheetLocalization
        .ImportImageHighTech.title,
      walletDescription: OChatStrings.MyNewWalletSheetLocalization
        .ImportImageHighTech.description,
      walletSystemImageName: "photo.artframe.circle"
    )
  }
  
  // TODO: - Добавлю позже этот функционал
  //  func createTrackWalletModel() -> MyNewWalletSheetModel {
  //    MyNewWalletSheetModel(
  //      walletTitle: OChatStrings.MyNewWalletSheetLocalization
  //        .TrackWallet.title,
  //      walletDescription: OChatStrings.MyNewWalletSheetLocalization
  //        .TrackWallet.description,
  //      walletSystemImageName: "eye.circle"
  //    )
  //  }
}

// MARK: - Private

private extension MyNewWalletSheetFactory {}

// MARK: - Constants

private enum Constants {}
