//
//  TorConnectScreenAbstractions.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 07.06.2024.
//

import SwiftUI

/// События которые отправляем из `TorConnectScreenModule` в `Coordinator`
public protocol TorConnectScreenModuleOutput: AnyObject {
  /// Запуск всех сервисов
  func stratTorConnectService()
  /// Сервисы все запущены
  func torServiceConnected()
  /// Перезагрузить сервисы
  func refreshTorConnectService()
}

/// События которые отправляем из `Coordinator` в `TorConnectScreenModule`
public protocol TorConnectScreenModuleInput {

  /// События которые отправляем из `TorConnectScreenModule` в `Coordinator`
  var moduleOutput: TorConnectScreenModuleOutput? { get set }
}

/// Готовый модуль `TorConnectScreenModule`
public typealias TorConnectScreenModule = (viewController: UIViewController, input: TorConnectScreenModuleInput)
