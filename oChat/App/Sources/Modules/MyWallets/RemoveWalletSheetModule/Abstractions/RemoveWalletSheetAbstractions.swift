//
//  RemoveWalletSheetAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SwiftUI

/// События которые отправляем из `RemoveWalletSheetModule` в `Coordinator`
public protocol RemoveWalletSheetModuleOutput: AnyObject {
  /// Кнопка удалить кошелек была нажата
  func removeWalletSheetWasTapped()
}

/// События которые отправляем из `Coordinator` в `RemoveWalletSheetModule`
public protocol RemoveWalletSheetModuleInput {

  /// События которые отправляем из `RemoveWalletSheetModule` в `Coordinator`
  var moduleOutput: RemoveWalletSheetModuleOutput? { get set }
}

/// Готовый модуль `RemoveWalletSheetModule`
public typealias RemoveWalletSheetModule = (viewController: UIViewController, input: RemoveWalletSheetModuleInput)
