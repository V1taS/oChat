//
//  HighTechImageIDInfoSheetPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class HighTechImageIDInfoSheetPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateButtonTitle = "Продолжить"
  
  // MARK: - Internal properties
  
  weak var moduleOutput: HighTechImageIDInfoSheetModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: HighTechImageIDInfoSheetInteractorInput
  private let factory: HighTechImageIDInfoSheetFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: HighTechImageIDInfoSheetInteractorInput,
       factory: HighTechImageIDInfoSheetFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
  
  func getHighTechImageIDProtectionModel() -> HighTechImageIDInfoSheetModel {
    factory.createHighTechImageIDProtectionModel()
  }
}

// MARK: - HighTechImageIDInfoSheetModuleInput

extension HighTechImageIDInfoSheetPresenter: HighTechImageIDInfoSheetModuleInput {}

// MARK: - HighTechImageIDInfoSheetInteractorOutput

extension HighTechImageIDInfoSheetPresenter: HighTechImageIDInfoSheetInteractorOutput {}

// MARK: - HighTechImageIDInfoSheetFactoryOutput

extension HighTechImageIDInfoSheetPresenter: HighTechImageIDInfoSheetFactoryOutput {}

// MARK: - SceneViewModel

extension HighTechImageIDInfoSheetPresenter: SceneViewModel {
  var backgroundColor: UIColor? {
    SKStyleAsset.sheet.color
  }
}

// MARK: - Private

private extension HighTechImageIDInfoSheetPresenter {}

// MARK: - Constants

private enum Constants {}
