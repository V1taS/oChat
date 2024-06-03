//
//  DetailPaymentScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 05.05.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `DetailPaymentScreenModule` в `Coordinator`
public protocol DetailPaymentScreenModuleOutput: AnyObject {
  /// Открыть экран отправки токенов
  func openSendPaymentScreen(_ tokenModel: TokenModel)
  /// Открыть экран получения токенов
  func openReceivePaymentScreen(_ tokenModel: TokenModel)
  /// Открыть экран транзакции
  func openTransactionInformationSheet(_ tokenModel: TokenModel)
}

/// События которые отправляем из `Coordinator` в `DetailPaymentScreenModule`
public protocol DetailPaymentScreenModuleInput {

  /// События которые отправляем из `DetailPaymentScreenModule` в `Coordinator`
  var moduleOutput: DetailPaymentScreenModuleOutput? { get set }
}

/// Готовый модуль `DetailPaymentScreenModule`
public typealias DetailPaymentScreenModule = (viewController: UIViewController, input: DetailPaymentScreenModuleInput)
