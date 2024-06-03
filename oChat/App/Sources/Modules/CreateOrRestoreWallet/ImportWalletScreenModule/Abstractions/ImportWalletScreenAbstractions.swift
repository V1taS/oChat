//
//  ImportWalletScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//

import SwiftUI

/// События которые отправляем из `ImportWalletScreenModule` в `Coordinator`
public protocol ImportWalletScreenModuleOutput: AnyObject {
  /// Пользователь нажал закрыть экран импорта кошелька
  func closeImportWalletScreenButtonTapped()
  
  /// Успешно импортировался кошелек
  func successImportWalletScreen()
}

/// События которые отправляем из `Coordinator` в `ImportWalletScreenModule`
public protocol ImportWalletScreenModuleInput {

  /// События которые отправляем из `ImportWalletScreenModule` в `Coordinator`
  var moduleOutput: ImportWalletScreenModuleOutput? { get set }
}

/// Готовый модуль `ImportWalletScreenModule`
public typealias ImportWalletScreenModule = (viewController: UIViewController, input: ImportWalletScreenModuleInput)
