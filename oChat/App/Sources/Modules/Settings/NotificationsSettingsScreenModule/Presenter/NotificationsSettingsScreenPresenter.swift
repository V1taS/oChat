//
//  NotificationsSettingsScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class NotificationsSettingsScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateWidgetCryptoModels: [WidgetCryptoView.Model] = []
  
  // MARK: - Internal properties
  
  weak var moduleOutput: NotificationsSettingsScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: NotificationsSettingsScreenInteractorInput
  private let factory: NotificationsSettingsScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: NotificationsSettingsScreenInteractorInput,
       factory: NotificationsSettingsScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    interactor.isNotificationsEnabled { [weak self] isEnabled in
      guard let self else {
        return
      }
      stateWidgetCryptoModels = factory.createWidgetModels(isEnabled)
    }
  }
  
  // MARK: - Internal func
}

// MARK: - NotificationsSettingsScreenModuleInput

extension NotificationsSettingsScreenPresenter: NotificationsSettingsScreenModuleInput {}

// MARK: - NotificationsSettingsScreenInteractorOutput

extension NotificationsSettingsScreenPresenter: NotificationsSettingsScreenInteractorOutput {}

// MARK: - NotificationsSettingsScreenFactoryOutput

extension NotificationsSettingsScreenPresenter: NotificationsSettingsScreenFactoryOutput {
  func changeNotificationsState(_ value: Bool) {
    if value {
      interactor.requestNotification { [weak self] granted in
        guard let self else {
          return
        }
        stateWidgetCryptoModels = factory.createWidgetModels(granted)
      }
      return
    }
  }
}

// MARK: - SceneViewModel

extension NotificationsSettingsScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
    .always
  }
}

// MARK: - Private

private extension NotificationsSettingsScreenPresenter {}

// MARK: - Constants

private enum Constants {}
