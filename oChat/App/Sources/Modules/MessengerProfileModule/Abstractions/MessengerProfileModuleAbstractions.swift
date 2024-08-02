//
//  MessengerProfileModuleAbstractions.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import SwiftUI

/// События которые отправляем из `MessengerProfileModuleModule` в `Coordinator`
public protocol MessengerProfileModuleModuleOutput: AnyObject {
  /// Кнопка закрыть была нажата
  func closeMessengerProfileScreenTapped()
  /// Кнопка поделиться была нажата
  func shareQRMessengerProfileScreenTapped(_ image: UIImage?, name: String)
}

/// События которые отправляем из `Coordinator` в `MessengerProfileModuleModule`
public protocol MessengerProfileModuleModuleInput {

  /// События которые отправляем из `MessengerProfileModuleModule` в `Coordinator`
  var moduleOutput: MessengerProfileModuleModuleOutput? { get set }
}

/// Готовый модуль `MessengerProfileModuleModule`
public typealias MessengerProfileModule = (viewController: UIViewController, input: MessengerProfileModuleModuleInput)
