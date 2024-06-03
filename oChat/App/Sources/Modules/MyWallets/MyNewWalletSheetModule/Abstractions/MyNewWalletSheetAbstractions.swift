//
//  MyNewWalletSheetAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI

/// События которые отправляем из `MyNewWalletSheetModule` в `Coordinator`
public protocol MyNewWalletSheetModuleOutput: AnyObject {
  /// Открыть экран создания кошелька с сид фразой 12 слов
  func openCreateStandartSeedPhrase12WalletScreen()
  /// Открыть экран создания кошелька с сид фразой 24 слова
  func openCreateIndestructibleSeedPhrase24WalletScreen()
  /// Открыть экран создания кошелька с изображением
  func openCreateHighTechImageIDWalletScreen()
  
  /// Открыть экран восстановления кошелька с сид фразой
  func openImportSeedPhraseWalletScreen()
  /// Открыть экран восстановления кошелька с изображением
  func openImportImageHighTechWalletScreen()
  /// Открыть экран восстановления кошелька для отслеживания
  func openImportTrackWalletWalletScreen()
}

/// События которые отправляем из `Coordinator` в `MyNewWalletSheetModule`
public protocol MyNewWalletSheetModuleInput {
  
  /// События которые отправляем из `MyNewWalletSheetModule` в `Coordinator`
  var moduleOutput: MyNewWalletSheetModuleOutput? { get set }
}

/// Готовый модуль `MyNewWalletSheetModule`
public typealias MyNewWalletSheetModule = (viewController: UIViewController, input: MyNewWalletSheetModuleInput)
