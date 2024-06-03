//
//  MessengerDialogScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class MessengerDialogScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateInputMessengeText = ""
  @Published var stateIsEnabledRightButton = true
  @Published var stateBottomHelper: String?
  @Published var stateIsErrorInputText = false
  @Published var stateIsEnabledInputText = true
  @Published var stateMaxLengthInputText = 100
  @Published var stateMessenges: [MessengerDialogModel.MessengeModel] = []
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MessengerDialogScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: MessengerDialogScreenInteractorInput
  private let factory: MessengerDialogScreenFactoryInput
  private let dialogModel: MessengerDialogModel
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - dialogModel: Моделька с данными
  init(interactor: MessengerDialogScreenInteractorInput,
       factory: MessengerDialogScreenFactoryInput,
       dialogModel: MessengerDialogModel) {
    self.interactor = interactor
    self.factory = factory
    self.dialogModel = dialogModel
    self.stateMessenges = dialogModel.messenges
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
  
  func refreshable() {
#warning("TODO: - Обновляем табличку")
  }
  
  func sendMessage() {
    interactor.sendMessage(stateInputMessengeText)
  }
  
  func getPlaceholder() -> String {
    factory.createPlaceholder()
  }
}

// MARK: - MessengerDialogScreenModuleInput

extension MessengerDialogScreenPresenter: MessengerDialogScreenModuleInput {}

// MARK: - MessengerDialogScreenInteractorOutput

extension MessengerDialogScreenPresenter: MessengerDialogScreenInteractorOutput {
  func didSendMessageSuccess() {
    stateMessenges.append(
      MessengerDialogModel.MessengeModel(messengeType: .own, message: stateInputMessengeText, date: Date())
    )
  }
  
  func didSendMessageFailure() {
    interactor.showNotification(
      .negative(
        title: OChatStrings.MessengerDialogScreenLocalization
          .State.Notification.messageFailure
      )
    )
  }
}

// MARK: - MessengerDialogScreenFactoryOutput

extension MessengerDialogScreenPresenter: MessengerDialogScreenFactoryOutput {}

// MARK: - SceneViewModel

extension MessengerDialogScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle(dialogModel: dialogModel)
  }
  
  var isEndEditing: Bool {
    true
  }
}

// MARK: - Private

private extension MessengerDialogScreenPresenter {}

// MARK: - Constants

private enum Constants {}
