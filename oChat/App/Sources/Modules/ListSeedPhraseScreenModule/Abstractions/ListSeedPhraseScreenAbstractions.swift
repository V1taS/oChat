//
//  ListSeedPhraseScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI

/// События которые отправляем из `ListSeedPhraseScreenModule` в `Coordinator`
public protocol ListSeedPhraseScreenModuleOutput: AnyObject {
  /// Пользователь сохранил сид вразу и нажал продолжить
  func saveListSeedAndContinueButtonTapped()
  
  /// Пользователь нажал закрыть экран
  func closeListSeedScreenButtonTapped()
}

/// События которые отправляем из `Coordinator` в `ListSeedPhraseScreenModule`
public protocol ListSeedPhraseScreenModuleInput {

  /// События которые отправляем из `ListSeedPhraseScreenModule` в `Coordinator`
  var moduleOutput: ListSeedPhraseScreenModuleOutput? { get set }
}

/// Готовый модуль `ListSeedPhraseScreenModule`
public typealias ListSeedPhraseScreenModule = (viewController: UIViewController, input: ListSeedPhraseScreenModuleInput)
