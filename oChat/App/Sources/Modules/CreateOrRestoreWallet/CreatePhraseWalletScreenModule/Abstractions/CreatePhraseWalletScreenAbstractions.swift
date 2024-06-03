//
//  CreatePhraseWalletScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `CreatePhraseWalletScreenModule` в `Coordinator`
public protocol CreatePhraseWalletScreenModuleOutput: AnyObject {
  /// Кошелек был создан
  func walletSeedPhraseHasBeenCreated(_ walletModel: WalletModel)
}

/// События которые отправляем из `Coordinator` в `CreatePhraseWalletScreenModule`
public protocol CreatePhraseWalletScreenModuleInput {

  /// События которые отправляем из `CreatePhraseWalletScreenModule` в `Coordinator`
  var moduleOutput: CreatePhraseWalletScreenModuleOutput? { get set }
}

/// Готовый модуль `CreatePhraseWalletScreenModule`
public typealias CreatePhraseWalletScreenModule = (viewController: UIViewController, input: CreatePhraseWalletScreenModuleInput)
