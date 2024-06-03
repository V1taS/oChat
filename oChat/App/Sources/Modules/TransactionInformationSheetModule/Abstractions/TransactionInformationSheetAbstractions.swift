//
//  TransactionInformationSheetAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 07.05.2024.
//

import SwiftUI

/// События которые отправляем из `TransactionInformationSheetModule` в `Coordinator`
public protocol TransactionInformationSheetModuleOutput: AnyObject {}

/// События которые отправляем из `Coordinator` в `TransactionInformationSheetModule`
public protocol TransactionInformationSheetModuleInput {

  /// События которые отправляем из `TransactionInformationSheetModule` в `Coordinator`
  var moduleOutput: TransactionInformationSheetModuleOutput? { get set }
}

/// Готовый модуль `TransactionInformationSheetModule`
public typealias TransactionInformationSheetModule = (viewController: UIViewController, input: TransactionInformationSheetModuleInput)
