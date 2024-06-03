//
//  CurrencyListScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI

/// События которые отправляем из `CurrencyListScreenModule` в `Coordinator`
public protocol CurrencyListScreenModuleOutput: AnyObject {}

/// События которые отправляем из `Coordinator` в `CurrencyListScreenModule`
public protocol CurrencyListScreenModuleInput {

  /// События которые отправляем из `CurrencyListScreenModule` в `Coordinator`
  var moduleOutput: CurrencyListScreenModuleOutput? { get set }
}

/// Готовый модуль `CurrencyListScreenModule`
public typealias CurrencyListScreenModule = (viewController: UIViewController, input: CurrencyListScreenModuleInput)
