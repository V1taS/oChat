//
//  SuggestScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class SuggestScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateSuggestScreen: SuggestScreenState
  
  // MARK: - Internal properties
  
  weak var moduleOutput: SuggestScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: SuggestScreenInteractorInput
  private let factory: SuggestScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - state: Тип экрана
  init(interactor: SuggestScreenInteractorInput,
       factory: SuggestScreenFactoryInput,
       _ state: SuggestScreenState) {
    self.interactor = interactor
    self.factory = factory
    self.stateSuggestScreen = state
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
  
  func getSuggestModel() -> SuggestScreenModel {
    factory.createSuggestModel(stateSuggestScreen)
  }
  
  func suggestScreenConfirmButtonTapped() async {
    switch stateSuggestScreen {
    case .setAccessCode:
      moduleOutput?.suggestAccessCodeScreenConfirmButtonTapped()
    case .setFaceID:
      let granted = await interactor.requestFaceID()
      await interactor.setIsEnabledFaceID(granted)
      let isEnabled = await interactor.isNotificationsEnabled()
      moduleOutput?.suggestFaceIDScreenConfirmButtonTapped(isEnabled)
    case .setNotifications:
      let isNotification = await interactor.requestNotification()
      await interactor.setIsEnabledNotifications(isNotification)
      moduleOutput?.suggestNotificationScreenConfirmButtonTapped()
    }
  }
}

// MARK: - SuggestScreenModuleInput

extension SuggestScreenPresenter: SuggestScreenModuleInput {}

// MARK: - SuggestScreenInteractorOutput

extension SuggestScreenPresenter: SuggestScreenInteractorOutput {}

// MARK: - SuggestScreenFactoryOutput

extension SuggestScreenPresenter: SuggestScreenFactoryOutput {}

// MARK: - SceneViewModel

extension SuggestScreenPresenter: SceneViewModel {
  var rightBarButtonItem: SKBarButtonItem? {
    return .init(
      .text(
        OChatStrings.SuggestScreenLocalization.State.RightBarButton.title,
        action: {
          Task { [weak self] in
            guard let self else { return }
            switch stateSuggestScreen {
            case .setAccessCode, .setFaceID:
              let isEnabled = await interactor.isNotificationsEnabled()
              moduleOutput?.skipSuggestAccessCodeScreenButtonTapped(isEnabled)
            case .setNotifications:
              moduleOutput?.skipSuggestNotificationsScreenButtonTapped()
            }
          }
        }
      )
    )
  }
}

// MARK: - Private

private extension SuggestScreenPresenter {}

// MARK: - Constants

private enum Constants {}
