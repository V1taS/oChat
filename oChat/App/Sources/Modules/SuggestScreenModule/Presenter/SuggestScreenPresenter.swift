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
  
  func suggestScreenConfirmButtonTapped() {
    switch stateSuggestScreen {
    case .setAccessCode:
      moduleOutput?.suggestAccessCodeScreenConfirmButtonTapped()
    case .setFaceID:
      interactor.requestFaceID { [weak self] granted in
        guard let self else {
          return
        }
        
        interactor.setIsEnabledFaceID(granted) { [weak self] in
          guard let self else {
            return
          }
          
          interactor.isNotificationsEnabled { [weak self] isEnabled in
            guard let self else {
              return
            }
            
            moduleOutput?.suggestFaceIDScreenConfirmButtonTapped(isEnabled)
          }
        }
      }
    case .setNotifications:
      interactor.requestNotification { [weak self] isNotification in
        guard let self else {
          return
        }
        interactor.setIsEnabledNotifications(isNotification) { [weak self] in
          guard let self else {
            return
          }
          
          moduleOutput?.suggestNotificationScreenConfirmButtonTapped()
        }
      }
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
        action: { [weak self] in
          guard let self else {
            return
          }
          
          switch stateSuggestScreen {
          case .setAccessCode, .setFaceID:
            interactor.isNotificationsEnabled { [weak self] isEnabled in
              guard let self else {
                return
              }
              moduleOutput?.skipSuggestAccessCodeScreenButtonTapped(isEnabled)
            }
          case .setNotifications:
            moduleOutput?.skipSuggestNotificationsScreenButtonTapped()
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
