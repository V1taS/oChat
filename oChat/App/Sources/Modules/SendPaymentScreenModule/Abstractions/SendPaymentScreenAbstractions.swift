//
//  SendPaymentScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `SendPaymentScreenModule` в `Coordinator`
public protocol SendPaymentScreenModuleOutput: AnyObject {
  /// Открыть экран со списком токенов для выбора
  func openListTokensScreen(_ model: TokenModel)
  /// Открыть экран со списком сетей в блокчейне для выбора
  func openNetworkTokensScreen(_ model: TokenModel)
  /// Открыть экран подтвердить отправку токенов
  func openConfirmAndSendScreen(_ model: TokenModel, recipientAddress: String)
  /// Пользователь нажал закрыть экран
  func closeSendPaymentScreenButtonTapped()
}

/// События которые отправляем из `Coordinator` в `SendPaymentScreenModule`
public protocol SendPaymentScreenModuleInput {
  /// Токен был выбран
  func tokenSelected(_ model: TokenModel)
  /// Сеть блок чейна выбрана был выбран
  func networkSelected(_ model: TokenNetworkType)

  /// События которые отправляем из `SendPaymentScreenModule` в `Coordinator`
  var moduleOutput: SendPaymentScreenModuleOutput? { get set }
}

/// Готовый модуль `SendPaymentScreenModule`
public typealias SendPaymentScreenModule = (viewController: UIViewController, input: SendPaymentScreenModuleInput)
