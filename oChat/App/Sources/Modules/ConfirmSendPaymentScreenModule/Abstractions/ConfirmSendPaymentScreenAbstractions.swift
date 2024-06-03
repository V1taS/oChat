//
//  ConfirmSendPaymentScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import SwiftUI

/// События которые отправляем из `ConfirmSendPaymentScreenModule` в `Coordinator`
public protocol ConfirmSendPaymentScreenModuleOutput: AnyObject {
  /// Платеж успешно отправлен
  func paymentSentSuccessfully()
  /// Платеж не отправлен
  func paymentNotSent()
}

/// События которые отправляем из `Coordinator` в `ConfirmSendPaymentScreenModule`
public protocol ConfirmSendPaymentScreenModuleInput {

  /// События которые отправляем из `ConfirmSendPaymentScreenModule` в `Coordinator`
  var moduleOutput: ConfirmSendPaymentScreenModuleOutput? { get set }
}

/// Готовый модуль `ConfirmSendPaymentScreenModule`
public typealias ConfirmSendPaymentScreenModule = (viewController: UIViewController, input: ConfirmSendPaymentScreenModuleInput)
