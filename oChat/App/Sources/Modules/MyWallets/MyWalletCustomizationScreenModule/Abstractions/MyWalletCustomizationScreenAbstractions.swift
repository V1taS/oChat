//
//  MyWalletCustomizationScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `MyWalletCustomizationScreenModule` в `Coordinator`
public protocol MyWalletCustomizationScreenModuleOutput: AnyObject {
  /// Вызывается, когда нажата кнопка "Подтвердить настройку".
  func confirmCustomizationButtonPressed(_ walletModel: WalletModel)
}

/// События которые отправляем из `Coordinator` в `MyWalletCustomizationScreenModule`
public protocol MyWalletCustomizationScreenModuleInput {

  /// События которые отправляем из `MyWalletCustomizationScreenModule` в `Coordinator`
  var moduleOutput: MyWalletCustomizationScreenModuleOutput? { get set }
}

/// Готовый модуль `MyWalletCustomizationScreenModule`
public typealias MyWalletCustomizationScreenModule = (viewController: UIViewController, input: MyWalletCustomizationScreenModuleInput)
