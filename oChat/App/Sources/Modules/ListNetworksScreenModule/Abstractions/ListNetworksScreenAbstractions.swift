//
//  ListNetworksScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из `ListNetworksScreenModule` в `Coordinator`
public protocol ListNetworksScreenModuleOutput: AnyObject {
  /// Сеть блок чейна выбрана был выбран
  func networkSelected(_ model: TokenNetworkType)
}

/// События которые отправляем из `Coordinator` в `ListNetworksScreenModule`
public protocol ListNetworksScreenModuleInput {

  /// События которые отправляем из `ListNetworksScreenModule` в `Coordinator`
  var moduleOutput: ListNetworksScreenModuleOutput? { get set }
}

/// Готовый модуль `ListNetworksScreenModule`
public typealias ListNetworksScreenModule = (viewController: UIViewController, input: ListNetworksScreenModuleInput)
