//
//  MessengerNewMessengeScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class MessengerNewMessengeScreenPresenter: ObservableObject {

  // MARK: - View state

  @Published var stateButtonTitle = "Продолжить"
  @Published var recipientName = ""
  let costOfSendingMessage: String

  // MARK: - Internal properties

  weak var moduleOutput: MessengerNewMessengeScreenModuleOutput?

  // MARK: - Private properties

  private let interactor: MessengerNewMessengeScreenInteractorInput
  private let factory: MessengerNewMessengeScreenFactoryInput

  // MARK: - Initialization

  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: MessengerNewMessengeScreenInteractorInput,
       factory: MessengerNewMessengeScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
    costOfSendingMessage = factory.getCostOfSendingMessage()
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}

  // MARK: - Internal func
}

// MARK: - MessengerNewMessengeScreenModuleInput

extension MessengerNewMessengeScreenPresenter: MessengerNewMessengeScreenModuleInput {}

// MARK: - MessengerNewMessengeScreenInteractorOutput

extension MessengerNewMessengeScreenPresenter: MessengerNewMessengeScreenInteractorOutput {}

// MARK: - MessengerNewMessengeScreenFactoryOutput

extension MessengerNewMessengeScreenPresenter: MessengerNewMessengeScreenFactoryOutput {
  func openNewMessageDialogScreen(messageModel: MessengerDialogModel.MessengeModel) {
    moduleOutput?.openNewMessageDialogScreen(
      dialogModel: MessengerDialogModel(
        senderName: factory.getSenderName(),
        recipientName: recipientName,
        messenges: [messageModel],
        costOfSendingMessage: factory.getCostOfSendingMessage(),
        isHiddenDialog: false
      )
    )
  }
}

// MARK: - SceneViewModel

extension MessengerNewMessengeScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }

  var isEndEditing: Bool {
    true
  }

  var rightBarButtonItem: SKBarButtonItem? {
    .init(.close(action: { [weak self] in
      self?.moduleOutput?.closeNewMessengeScreenButtonTapped()
    }))
  }
}

// MARK: - Private

private extension MessengerNewMessengeScreenPresenter {}

// MARK: - Constants

private enum Constants {}
