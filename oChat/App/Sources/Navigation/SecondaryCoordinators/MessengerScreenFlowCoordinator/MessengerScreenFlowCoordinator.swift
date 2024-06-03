//
//  MessengerScreenFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

final class MessengerScreenFlowCoordinator: Coordinator<Void, MessengerScreenFinishFlowType> {
  
  // MARK: - Internal variables
  
  var navigationController: UINavigationController?
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  private var messengerListScreenModuleModule: MessengerListScreenModuleModule?
  private var messengerDialogModule: MessengerDialogScreenModule?
  private var messengerNewMessengeScreenModule: MessengerNewMessengeScreenModule?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы приложения
  init(_ services: IApplicationServices) {
    self.services = services
  }
  
  // MARK: - Internal func
  
  override func start(parameter: Void) {
    var messengerListScreenModuleModule = MessengerListScreenModuleAssembly(
      messengerDialogModels: createListDialogModels()
    ).createModule()
    self.messengerListScreenModuleModule = messengerListScreenModuleModule
    messengerListScreenModuleModule.input.moduleOutput = self
    navigationController = messengerListScreenModuleModule.viewController.wrapToNavigationController()
  }
}

// MARK: - MessengerListScreenModuleModuleOutput

extension MessengerScreenFlowCoordinator: MessengerListScreenModuleModuleOutput {
  func openNewMessengeScreen() {
    openMessengerNewMessengeScreenModule()
  }
  
  func openMessengerDialogScreen(dialogModel: MessengerDialogModel) {
    openMessengerDialogModule(dialogModel: dialogModel)
  }
}

// MARK: - MessengerDialogScreenModuleOutput

extension MessengerScreenFlowCoordinator: MessengerDialogScreenModuleOutput {}

// MARK: - MessengerNewMessengeScreenModuleOutput

extension MessengerScreenFlowCoordinator: MessengerNewMessengeScreenModuleOutput {
  func closeNewMessengeScreenButtonTapped() {
    messengerNewMessengeScreenModule?.viewController.dismiss(animated: true)
    messengerNewMessengeScreenModule = nil
  }

  func openNewMessageDialogScreen(dialogModel: MessengerDialogModel) {
    // TODO: надо сделать переход как в iMessage
    // https://github.com/V1taS/oChat/issues/33
    messengerNewMessengeScreenModule?.viewController.dismiss(animated: true)
    messengerNewMessengeScreenModule = nil

    messengerListScreenModuleModule?.input.updateList(dialogModel: dialogModel)
    openMessengerDialogScreen(dialogModel: dialogModel)
  }
}

// MARK: - Open modules

private extension MessengerScreenFlowCoordinator {
  func openMessengerDialogModule(dialogModel: MessengerDialogModel) {
    var messengerDialogModule = MessengerDialogScreenAssembly().createModule(
      dialogModel: dialogModel,
      services: services
    )
    self.messengerDialogModule = messengerDialogModule
    messengerDialogModule.input.moduleOutput = self
    
    messengerDialogModule.viewController.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(messengerDialogModule.viewController, animated: true)
  }
  
  func openMessengerNewMessengeScreenModule() {
    // TODO: Надо откуда-то забирать данные
    // https://github.com/V1taS/oChat/issues/32
    var messengerNewMessengeScreenModule = MessengerNewMessengeScreenAssembly()
      .createModule(senderName: "Volodya", costOfSendingMessage: "Для меня бесплатно")
    self.messengerNewMessengeScreenModule = messengerNewMessengeScreenModule
    messengerNewMessengeScreenModule.input.moduleOutput = self
    
    navigationController?.present(
      messengerNewMessengeScreenModule.viewController.wrapToNavigationController(),
      animated: true
    )
  }
}

// MARK: - Private

private extension MessengerScreenFlowCoordinator {
  func finishMessengerFlow(_ flowType: MessengerScreenFinishFlowType) {
    messengerListScreenModuleModule = nil
    messengerDialogModule = nil
    messengerNewMessengeScreenModule = nil
    finishFlow?(flowType)
  }
}

extension MessengerScreenFlowCoordinator {
  private func createListDialogModels() -> [MessengerDialogModel] {
    var models: [MessengerDialogModel] = []

    (1...20).forEach { _ in
      models.append(
        MessengerDialogModel(
          senderName: "UQC9vCFrizDwENt5fWq7Vb76l55MUgdWk9yJwDYyHP3jY6Fo",
          recipientName: "UQC9FwfwFwf7Vb76l55MUgdWk9yJwDYyHP3jY6Fo",
          messenges: [
            .init(
              messengeType: .own,
              message: "Привет 😀",
              date: Date()
            ),
            .init(
              messengeType: .received,
              message: "Привет, ты как?",
              date: Date()
            ),
            .init(
              messengeType: .own,
              message: "Отлично, ты как?",
              date: Date()
            ),
            .init(
              messengeType: .received,
              message: "Хорошо, спасибо. Пришли пожалуйста денег 1 000 000 баксов на мой крипто кошелек",
              date: Date()
            )
          ],
          costOfSendingMessage: "Стоимость отправки сообщения = 1 цент",
          isHiddenDialog: false
        )
      )
    }
    return models
  }
}
