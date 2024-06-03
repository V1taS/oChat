//
//  MyWalletsScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `MyWalletsScreenModule` в `Coordinator`
public protocol MyWalletsScreenModuleOutput: AnyObject {
  /// Открыть экран настройки кошелька
  func openMyWalletSettingsScreen(_ walletModel: WalletModel)
  /// Открыть шторку для добавления нового кошелька
  func openAddNewWalletSheet()
}

/// События которые отправляем из `Coordinator` в `MyWalletsScreenModule`
public protocol MyWalletsScreenModuleInput {

  /// События которые отправляем из `MyWalletsScreenModule` в `Coordinator`
  var moduleOutput: MyWalletsScreenModuleOutput? { get set }
}

/// Готовый модуль `MyWalletsScreenModule`
public typealias MyWalletsScreenModule = (viewController: UIViewController, input: MyWalletsScreenModuleInput)
