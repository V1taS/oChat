//
//  HighTechImageIDInfoSheetAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//

import SwiftUI

/// События которые отправляем из `HighTechImageIDInfoSheetModule` в `Coordinator`
public protocol HighTechImageIDInfoSheetModuleOutput: AnyObject {}

/// События которые отправляем из `Coordinator` в `HighTechImageIDInfoSheetModule`
public protocol HighTechImageIDInfoSheetModuleInput {

  /// События которые отправляем из `HighTechImageIDInfoSheetModule` в `Coordinator`
  var moduleOutput: HighTechImageIDInfoSheetModuleOutput? { get set }
}

/// Готовый модуль `HighTechImageIDInfoSheetModule`
public typealias HighTechImageIDInfoSheetModule = (viewController: UIViewController, input: HighTechImageIDInfoSheetModuleInput)
