//
//  AppearanceAppScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class AppearanceAppScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateWidgetCryptoModels: [SKUIKit.WidgetCryptoView.Model] = []
  
  // MARK: - Internal properties
  
  weak var moduleOutput: AppearanceAppScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: AppearanceAppScreenInteractorInput
  private let factory: AppearanceAppScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: AppearanceAppScreenInteractorInput,
       factory: AppearanceAppScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    let colorScheme = interactor.getColorScheme()
    stateWidgetCryptoModels = factory.createWidgetModels(colorScheme)
  }
  
  // MARK: - Internal func
}

// MARK: - AppearanceAppScreenModuleInput

extension AppearanceAppScreenPresenter: AppearanceAppScreenModuleInput {}

// MARK: - AppearanceAppScreenInteractorOutput

extension AppearanceAppScreenPresenter: AppearanceAppScreenInteractorOutput {}

// MARK: - AppearanceAppScreenFactoryOutput

extension AppearanceAppScreenPresenter: AppearanceAppScreenFactoryOutput {
  func saveColorScheme(_ interfaceStyle: UIUserInterfaceStyle?) {
    interactor.saveColorScheme(interfaceStyle)
    let colorScheme = interactor.getColorScheme()
    stateWidgetCryptoModels = factory.createWidgetModels(colorScheme)
    UIApplication.currentWindow?.overrideUserInterfaceStyle = colorScheme ?? .unspecified
  }
}

// MARK: - SceneViewModel

extension AppearanceAppScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
    .always
  }
}

// MARK: - Private

private extension AppearanceAppScreenPresenter {}

// MARK: - Constants

private enum Constants {}
