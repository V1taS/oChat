//
//  MyWalletSettingsScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol MyWalletSettingsScreenFactoryOutput: AnyObject {
  /// Открыть предупреждение по удалению кошелька
  func openDeleteWalletSheet()
  /// Открыть экран с СИД фразой
  func openRecoveryPhraseScreen(_ walletModel: WalletModel)
  /// Открыть экран с ImageID
  func openRecoveryImageIDScreen(_ walletModel: WalletModel)
  /// Открыть экран переименовать кошелек
  func openRenameWalletScreen(_ walletModel: WalletModel)
  /// Был изменен статус для кошелька
  func onChangeIsPrimary(_ value: Bool)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol MyWalletSettingsScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать первичные виджеты модельки для отображения
  func createPrimaryWidgetModels(isPrimary: Bool) -> [WidgetCryptoView.Model]
  /// Создать вторичные виджеты модельки для отображения
  func createSecondaryWidgetModels(_ walletModel: WalletModel) -> [WidgetCryptoView.Model]
  /// Создать третичную виджеты модельки для отображения
  func createTertiaryWidgetModels() -> [WidgetCryptoView.Model]
}

/// Фабрика
final class MyWalletSettingsScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: MyWalletSettingsScreenFactoryOutput?
}

// MARK: - MyWalletSettingsScreenFactoryInput

extension MyWalletSettingsScreenFactory: MyWalletSettingsScreenFactoryInput {
  func createHeaderTitle() -> String {
    oChatStrings.MyWalletSettingsScreenLocalization
      .State.Header.title
  }
  
  func createPrimaryWidgetModels(isPrimary: Bool) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    let mainWalletModel = createWidgetWithSwitcher(
      title: oChatStrings.MyWalletSettingsScreenLocalization
        .Section.Primary.title,
      isPrimary: isPrimary) { [weak self] newValue in
        self?.output?.onChangeIsPrimary(newValue)
      }
    
    models = [
      mainWalletModel
    ]
    return models
  }
  
  func createSecondaryWidgetModels(_ walletModel: WalletModel) -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    let renameWalletModel = createWidget(
      title: oChatStrings.MyWalletSettingsScreenLocalization
        .Section.RenameWallet.title,
      action: { [weak self] in
        self?.output?.openRenameWalletScreen(walletModel)
      }
    )
    models.append(renameWalletModel)
    
    if walletModel.walletType.isHighTechImageID {
      let showRecoveryImageIDModel = createWidget(
        title: oChatStrings.MyWalletSettingsScreenLocalization
          .Section.ShowRecoveryImageID.title,
        action: { [weak self] in
          self?.output?.openRecoveryImageIDScreen(walletModel)
        }
      )
      models.append(showRecoveryImageIDModel)
    } else {
      let showRecoveryPhraseModel = createWidget(
        title: oChatStrings.MyWalletSettingsScreenLocalization
          .Section.ShowRecoveryPhrase.title,
        action: { [weak self] in
          self?.output?.openRecoveryPhraseScreen(walletModel)
        }
      )
      models.append(showRecoveryPhraseModel)
    }
    return models
  }
  
  func createTertiaryWidgetModels() -> [WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    let deleteWalletModel = createWidget(
      title: oChatStrings.MyWalletSettingsScreenLocalization
        .Section.DeleteWallet.title,
      isNegative: true,
      action: { [weak self] in
        self?.output?.openDeleteWalletSheet()
      }
    )
    
    models = [
      deleteWalletModel
    ]
    return models
  }
}

// MARK: - Private

private extension MyWalletSettingsScreenFactory {
  func createWidget(
    title: String,
    isNegative: Bool = false,
    action: (() -> Void)?
  ) -> WidgetCryptoView.Model {
    var descriptionModel: WidgetCryptoView.TextModel?
    
    if isNegative {
      descriptionModel = .init(text: title, textStyle: .negative)
    } else {
      descriptionModel = .init(text: title, textStyle: .standart)
    }
    
    return .init(
      leftSide: .init(
        titleModel: nil,
        descriptionModel: descriptionModel
      ),
      rightSide: .init(
        imageModel: .chevron
      ),
      action: action
    )
  }
  
  func createWidgetWithSwitcher(
    title: String,
    isPrimary: Bool,
    action: ((_ newValue: Bool) -> Void)?
  ) -> WidgetCryptoView.Model {
    return .init(
      leftSide: .init(
        descriptionModel: .init(
          text: title,
          textStyle: .standart
        )
      ),
      rightSide: .init(
        itemModel: .switcher(
          initNewValue: isPrimary,
          action: action
        )
      ),
      isSelectable: false
    )
  }
}

// MARK: - Constants

private enum Constants {}
