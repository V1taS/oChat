//
//  MessengerListScreenModulePresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class MessengerListScreenModulePresenter: ObservableObject {
  
  // MARK: - View state
  @Published var dialogWidgetModels: [WidgetCryptoView.Model] = []

  // MARK: - Internal properties
  
  weak var moduleOutput: MessengerListScreenModuleModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: MessengerListScreenModuleInteractorInput
  private let factory: MessengerListScreenModuleFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(
    interactor: MessengerListScreenModuleInteractorInput,
    factory: MessengerListScreenModuleFactoryInput
  ) {
    self.interactor = interactor
    self.factory = factory

    dialogWidgetModels = self.factory.createDialogWidgetModels()
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
}

// MARK: - MessengerListScreenModuleModuleInput

extension MessengerListScreenModulePresenter: MessengerListScreenModuleModuleInput {
  func updateList(dialogModel: MessengerDialogModel) {
    dialogWidgetModels.insert(
      WidgetCryptoView.Model(
        leftSide: .init(
          imageModel: nil,
          itemModel: nil,
          titleModel: .init(
            text: dialogModel.recipientName,
            textStyle: .standart,
            textIsSecure: false
          ),
          titleAdditionRoundedModel: nil,
          descriptionModel: .init(
            text: dialogModel.messenges.last?.message ?? "",
            lineLimit: 2,
            textStyle: .netural,
            textIsSecure: false
          ),
          descriptionAdditionModel: nil,
          descriptionAdditionRoundedModel: nil
        ),
        rightSide: .init(
          imageModel: .chevron,
          itemModel: nil,
          titleModel: .init(
            text: "25.122023",
            textStyle: .netural,
            textIsSecure: false
          ),
          titleAdditionModel: nil,
          titleAdditionRoundedModel: nil,
          descriptionModel: nil,
          descriptionAdditionModel: nil,
          descriptionAdditionRoundedModel: nil
        ),
        isSelectable: true,
        backgroundColor: nil,
        action: { [weak self] in
          self?.openMessengerDialogScreen(dialogModel: dialogModel)
        }
      ),
      at: 0
    )
  }
}

// MARK: - MessengerListScreenModuleInteractorOutput

extension MessengerListScreenModulePresenter: MessengerListScreenModuleInteractorOutput {}

// MARK: - MessengerListScreenModuleFactoryOutput

extension MessengerListScreenModulePresenter: MessengerListScreenModuleFactoryOutput {
  func openMessengerDialogScreen(dialogModel: MessengerDialogModel) {
    moduleOutput?.openMessengerDialogScreen(dialogModel: dialogModel)
  }
}

// MARK: - SceneViewModel

extension MessengerListScreenModulePresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
    .always
  }
  
  var rightBarButtonItem: SKBarButtonItem? {
    .init(.write(action: { [weak self] in
      self?.moduleOutput?.openNewMessengeScreen()
    }))
  }
}

// MARK: - Private

private extension MessengerListScreenModulePresenter {}

// MARK: - Constants

private enum Constants {}
