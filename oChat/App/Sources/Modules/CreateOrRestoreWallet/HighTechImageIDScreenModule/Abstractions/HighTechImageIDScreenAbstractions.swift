//
//  HighTechImageIDScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SwiftUI

/// События которые отправляем из `HighTechImageIDScreenModule` в `Coordinator`
public protocol HighTechImageIDScreenModuleOutput: AnyObject {
  /// Кнопка закрыть была нажата
  func closeButtonHighTechImageIDScreenTapped()
  /// Открыть шторку с информацией о ImageID
  func openInfoImageIDSheet()
  /// Сохранить ImageID в галерею
  func saveHighTechImageIDToGallery(_ image: Data?)
  /// Успешное создание ImageID
  func successCreatedHighTechImageIDScreen()
  /// Успешный вход по ImageID
  func successLoginHighTechImageIDScreen()
}

/// События которые отправляем из `Coordinator` в `HighTechImageIDScreenModule`
public protocol HighTechImageIDScreenModuleInput {

  /// События которые отправляем из `HighTechImageIDScreenModule` в `Coordinator`
  var moduleOutput: HighTechImageIDScreenModuleOutput? { get set }
}

/// Готовый модуль `HighTechImageIDScreenModule`
public typealias HighTechImageIDScreenModule = (viewController: UIViewController, input: HighTechImageIDScreenModuleInput)
