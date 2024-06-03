//
//  CreateOrRestoreWalletSheetAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//

import SwiftUI

/// События которые отправляем из `CreateOrRestoreWalletSheetModule` в `Coordinator`
public protocol CreateOrRestoreWalletSheetModuleOutput: AnyObject {
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

/// События которые отправляем из `Coordinator` в `CreateOrRestoreWalletSheetModule`
public protocol CreateOrRestoreWalletSheetModuleInput {

  /// События которые отправляем из `CreateOrRestoreWalletSheetModule` в `Coordinator`
  var moduleOutput: CreateOrRestoreWalletSheetModuleOutput? { get set }
}

/// Готовый модуль `CreateOrRestoreWalletSheetModule`
public typealias CreateOrRestoreWalletSheetModule = (viewController: UIViewController, input: CreateOrRestoreWalletSheetModuleInput)
