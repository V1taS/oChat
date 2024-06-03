//
//  MainScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `MainScreenModule` в `Coordinator`
public protocol MainScreenModuleOutput: AnyObject {
  /// Открыть экран отправки криптовалюты
  func openSendCoinScreen()
  /// Открыть экран получения криптовалюты
  func openReceiveCoinScreen()
  /// Открыть экран добавление нового токена или выключения ненужных
  func openAddTokenScreen(tokenModels: [TokenModel])
  /// Открыть экран деталей по конкретной криптовалюте
  func openDetailCoinScreen(_ tokenModel: TokenModel)
}

/// События которые отправляем из `Coordinator` в `MainScreenModule`
public protocol MainScreenModuleInput {
  /// Обновить список токенов
  func updateTokens(_ tokenModels: [TokenModel])

  /// События которые отправляем из `MainScreenModule` в `Coordinator`
  var moduleOutput: MainScreenModuleOutput? { get set }
}

/// Готовый модуль `MainScreenModule`
public typealias MainScreenModule = (viewController: UIViewController, input: MainScreenModuleInput)
