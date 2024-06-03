//
//  SaveImageScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 22.05.2024.
//

import SwiftUI

/// События которые отправляем из `SaveImageScreenModule` в `Coordinator`
public protocol SaveImageScreenModuleOutput: AnyObject {
  /// Сохранить ImageID на телефон
  func saveImageIDButtonTapped(_ image: Data?)
}

/// События которые отправляем из `Coordinator` в `SaveImageScreenModule`
public protocol SaveImageScreenModuleInput {

  /// События которые отправляем из `SaveImageScreenModule` в `Coordinator`
  var moduleOutput: SaveImageScreenModuleOutput? { get set }
}

/// Готовый модуль `SaveImageScreenModule`
public typealias SaveImageScreenModule = (viewController: UIViewController, input: SaveImageScreenModuleInput)
