//
//  ActivityScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class ActivityScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateButtonTitle = "Продолжить"
  
  // MARK: - Internal properties
  
  weak var moduleOutput: ActivityScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: ActivityScreenInteractorInput
  private let factory: ActivityScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: ActivityScreenInteractorInput,
       factory: ActivityScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
  
  func refreshable() {
#warning("TODO: - Обновляем табличку")
  }
  
  func getListActivity() -> [ActivityScreenModel] {
    return []
//    factory.createListActivity()
  }
}

// MARK: - ActivityScreenModuleInput

extension ActivityScreenPresenter: ActivityScreenModuleInput {}

// MARK: - ActivityScreenInteractorOutput

extension ActivityScreenPresenter: ActivityScreenInteractorOutput {}

// MARK: - ActivityScreenFactoryOutput

extension ActivityScreenPresenter: ActivityScreenFactoryOutput {
  func openActivitySheet() {
    moduleOutput?.openActivitySheet()
  }
}

// MARK: - SceneViewModel

extension ActivityScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
    .always
  }
}

// MARK: - Private

private extension ActivityScreenPresenter {}

// MARK: - Constants

private enum Constants {}
