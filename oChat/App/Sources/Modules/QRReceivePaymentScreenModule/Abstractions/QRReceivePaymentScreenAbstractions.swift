//
//  QRReceivePaymentScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//

import SwiftUI

/// События которые отправляем из `QRReceivePaymentScreenModule` в `Coordinator`
public protocol QRReceivePaymentScreenModuleOutput: AnyObject {
  /// Кнопка закрыть была нажата
  func closeQRReceivePaymentScreenTapped()
  /// Кнопка поделиться была нажата
  func shareQRReceivePaymentScreenTapped(_ image: UIImage?, name: String)
}

/// События которые отправляем из `Coordinator` в `QRReceivePaymentScreenModule`
public protocol QRReceivePaymentScreenModuleInput {

  /// События которые отправляем из `QRReceivePaymentScreenModule` в `Coordinator`
  var moduleOutput: QRReceivePaymentScreenModuleOutput? { get set }
}

/// Готовый модуль `QRReceivePaymentScreenModule`
public typealias QRReceivePaymentScreenModule = (viewController: UIViewController, input: QRReceivePaymentScreenModuleInput)
