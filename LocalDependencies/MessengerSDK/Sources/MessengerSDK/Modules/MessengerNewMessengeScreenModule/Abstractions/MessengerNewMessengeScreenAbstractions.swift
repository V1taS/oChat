//
//  MessengerNewMessengeScreenAbstractions.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `MessengerNewMessengeScreenModule` в `Coordinator`
public protocol MessengerNewMessengeScreenModuleOutput: AnyObject {
  /// Пользователь нажал закрыть экран
  func closeNewMessengeScreenButtonTapped()
  
  /// Отправить запрос на переписку
  func sendInitiateChatFromNewMessenge(onionAddress: String)
}

/// События которые отправляем из `Coordinator` в `MessengerNewMessengeScreenModule`
public protocol MessengerNewMessengeScreenModuleInput {

  /// События которые отправляем из `MessengerNewMessengeScreenModule` в `Coordinator`
  var moduleOutput: MessengerNewMessengeScreenModuleOutput? { get set }
}

/// Готовый модуль `MessengerNewMessengeScreenModule`
public typealias MessengerNewMessengeScreenModule = (viewController: UIViewController, input: MessengerNewMessengeScreenModuleInput)
