//
//  HintBackupScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class HintBackupScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  // MARK: - Internal properties
  
  weak var moduleOutput: HintBackupScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: HintBackupScreenInteractorInput
  private let factory: HintBackupScreenFactoryInput
  private let hintType: HintBackupScreenType
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - hintType: Тип подсказки
  init(interactor: HintBackupScreenInteractorInput,
       factory: HintBackupScreenFactoryInput,
       hintType: HintBackupScreenType) {
    self.interactor = interactor
    self.factory = factory
    self.hintType = hintType
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
  
  func getHintModel() -> HintBackupScreenModel {
    factory.createModel(hintType)
  }
}

// MARK: - HintBackupScreenModuleInput

extension HintBackupScreenPresenter: HintBackupScreenModuleInput {}

// MARK: - HintBackupScreenInteractorOutput

extension HintBackupScreenPresenter: HintBackupScreenInteractorOutput {}

// MARK: - HintBackupScreenFactoryOutput

extension HintBackupScreenPresenter: HintBackupScreenFactoryOutput {}

// MARK: - SceneViewModel

extension HintBackupScreenPresenter: SceneViewModel {}

// MARK: - Private

private extension HintBackupScreenPresenter {}

// MARK: - Constants

private enum Constants {}
