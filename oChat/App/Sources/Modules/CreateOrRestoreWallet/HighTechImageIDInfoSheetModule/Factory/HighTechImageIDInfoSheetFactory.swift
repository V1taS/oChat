//
//  HighTechImageIDInfoSheetFactory.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol HighTechImageIDInfoSheetFactoryOutput: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol HighTechImageIDInfoSheetFactoryInput {
  /// Создать модель для включения защиты ImageID
  func createHighTechImageIDProtectionModel() -> HighTechImageIDInfoSheetModel
}

/// Фабрика
final class HighTechImageIDInfoSheetFactory {
  
  // MARK: - Internal properties
  
  weak var output: HighTechImageIDInfoSheetFactoryOutput?
}

// MARK: - HighTechImageIDInfoSheetFactoryInput

extension HighTechImageIDInfoSheetFactory: HighTechImageIDInfoSheetFactoryInput {
  func createHighTechImageIDProtectionModel() -> HighTechImageIDInfoSheetModel {
    HighTechImageIDInfoSheetModel(
      title: OChatStrings.HighTechImageIDInfoSheetLocalization
        .State.Sheet.title,
      description: OChatStrings.HighTechImageIDInfoSheetLocalization
        .State.Sheet.description
    )
  }
}

// MARK: - Private

private extension HighTechImageIDInfoSheetFactory {}

// MARK: - Constants

private enum Constants {}
