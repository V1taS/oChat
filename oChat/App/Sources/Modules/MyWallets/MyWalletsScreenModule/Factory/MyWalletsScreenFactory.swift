//
//  MyWalletsScreenFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Cобытия которые отправляем из Factory в Presenter
protocol MyWalletsScreenFactoryOutput: AnyObject {
  /// Открыть экран настройки кошелька
  func openMyWalletSettingsScreen(_ walletModel: WalletModel)
}

/// Cобытия которые отправляем от Presenter к Factory
protocol MyWalletsScreenFactoryInput {
  /// Создать заголовок для экрана
  func createHeaderTitle() -> String
  /// Создать заголовок для кнопки добавить
  func createRoundButtonTitle() -> String
  /// Создать виджет который отображает список кошельков
  func createWidgetWalletsModels(walletModels: [WalletModel], currency: String) -> [SKUIKit.WidgetCryptoView.Model]
}

/// Фабрика
final class MyWalletsScreenFactory {
  
  // MARK: - Internal properties
  
  weak var output: MyWalletsScreenFactoryOutput?
}

// MARK: - MyWalletsScreenFactoryInput

extension MyWalletsScreenFactory: MyWalletsScreenFactoryInput {
  func createWidgetWalletsModels(walletModels: [WalletModel], currency: String) -> [SKUIKit.WidgetCryptoView.Model] {
    var models: [WidgetCryptoView.Model] = []
    
    walletModels.forEach { wallet in
      let firstWallet = createWidgetModel(
        walletName: wallet.name ?? "",
        walletBalance: wallet.totalTokenBalanceInCurrency.format(formatType: .precise),
        currentCurrency: currency,
        isSelectedWallet: wallet.isPrimary,
        action: { [weak self] in
          self?.output?.openMyWalletSettingsScreen(wallet)
        }
      )
      models.append(firstWallet)
    }
    
    return models
  }
  
  func createRoundButtonTitle() -> String {
    OChatStrings.MyWalletsScreenLocalization
      .State.RoundButton.title
  }
  
  func createHeaderTitle() -> String {
    OChatStrings.MyWalletsScreenLocalization
      .State.Header.title
  }
}

// MARK: - Private

private extension MyWalletsScreenFactory {
  func createWidgetModel(
    walletName: String,
    walletBalance: String,
    currentCurrency: String,
    isSelectedWallet: Bool,
    action: (() -> Void)?
  ) -> WidgetCryptoView.Model {
    var titleAdditionRoundedModel: WidgetCryptoView.TextModel?
    if isSelectedWallet {
      titleAdditionRoundedModel = .init(
        text: OChatStrings.MyWalletsScreenLocalization
          .State.Primary.title,
        lineLimit: 1,
        textStyle: .positive
      )
    }
    
    return .init(
      leftSide: .init(
        imageModel: nil,
        itemModel: nil,
        titleModel: .init(
          text: walletName,
          lineLimit: 1,
          textStyle: .standart
        ),
        titleAdditionRoundedModel: titleAdditionRoundedModel
      ),
      rightSide: .init(
        imageModel: .chevron,
        titleModel: .init(
          text: "\(walletBalance) \(currentCurrency)",
          lineLimit: 1,
          textStyle: .netural
        )
      ),
      action: action
    )
  }
}

// MARK: - Constants

private enum Constants {}
