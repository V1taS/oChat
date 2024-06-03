//
//  ReceivePaymentScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `ReceivePaymentScreenModule` в `Coordinator`
public protocol ReceivePaymentScreenModuleOutput: AnyObject {
  /// Кнопка закрыть экран была нажата
  func closeReceivePaymentScreenButtonTapped()
  /// Открыть экран выбора сети для Токена
  func openNetworkSelectionScreen(_ tokenModel: TokenModel)
  /// Открыть экран выбора Токена
  func openListTokensScreen(_ tokenModel: TokenModel)
  /// Кнопка продолжить была нажата
  func continueButtonReceivePaymentPressed(_ model: TokenModel)
}

/// События которые отправляем из `Coordinator` в `ReceivePaymentScreenModule`
public protocol ReceivePaymentScreenModuleInput {
  /// Обновить данные по токену
  func updateTokenModel(_ model: TokenModel)
  /// Обновить данные по сети
  func updateNetwork(_ model: SKAbstractions.TokenNetworkType)

  /// События которые отправляем из `ReceivePaymentScreenModule` в `Coordinator`
  var moduleOutput: ReceivePaymentScreenModuleOutput? { get set }
}

/// Готовый модуль `ReceivePaymentScreenModule`
public typealias ReceivePaymentScreenModule = (viewController: UIViewController, input: ReceivePaymentScreenModuleInput)
