//
//  MyWalletSettingsScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `MyWalletSettingsScreenModule` в `Coordinator`
public protocol MyWalletSettingsScreenModuleOutput: AnyObject {
  /// Открыть предупреждение по удалению кошелька
  func openDeleteWalletSheet()
  /// Открыть экран с СИД фразой
  func openRecoveryPhraseScreen(_ walletModel: WalletModel)
  /// Открыть экран переименовать кошелек
  func openRenameWalletScreen(_ walletModel: WalletModel)
  /// Кошелек был удален
  func walletSuccessfullyDeleted()
  /// Выйти из приложения
  func exitTheApplication()
  /// Открыть экран с ImageID
  func openRecoveryImageIDScreen(_ walletModel: WalletModel)
}

/// События которые отправляем из `Coordinator` в `MyWalletSettingsScreenModule`
public protocol MyWalletSettingsScreenModuleInput {
  /// Обновить контент
  func updateContent(_ walletModel: WalletModel)
  
  /// Удалить кошелек
  func deleteWallet()

  /// События которые отправляем из `MyWalletSettingsScreenModule` в `Coordinator`
  var moduleOutput: MyWalletSettingsScreenModuleOutput? { get set }
}

/// Готовый модуль `MyWalletSettingsScreenModule`
public typealias MyWalletSettingsScreenModule = (viewController: UIViewController, input: MyWalletSettingsScreenModuleInput)
