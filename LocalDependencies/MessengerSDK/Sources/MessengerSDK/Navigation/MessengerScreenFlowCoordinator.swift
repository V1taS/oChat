//
//  MessengerScreenFlowCoordinator.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

public final class MessengerScreenFlowCoordinator: Coordinator<Void, MessengerScreenFinishFlowType> {
  
  // MARK: - Internal variables
  
  public var navigationController: UINavigationController?
  
  // MARK: - Private variables
  
  private var attemptGetContactModel = 1
  private let services: IApplicationServices
  private var messengerListScreenModuleModule: MessengerListScreenModuleModule?
  private var messengerDialogModule: MessengerDialogScreenModule?
  private var messengerNewMessengeScreenModule: MessengerNewMessengeScreenModule?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы приложения
  public init(_ services: IApplicationServices) {
    self.services = services
  }
  
  // MARK: - Internal func
  
  public override func start(parameter: Void) {
    var messengerListScreenModuleModule = MessengerListScreenModuleAssembly().createModule(
      services: services
    )
    self.messengerListScreenModuleModule = messengerListScreenModuleModule
    messengerListScreenModuleModule.input.moduleOutput = self
    navigationController = messengerListScreenModuleModule.viewController.wrapToNavigationController()
  }
}

// MARK: - MessengerListScreenModuleModuleOutput

extension MessengerScreenFlowCoordinator: MessengerListScreenModuleOutput {
  public func dataModelHasBeenUpdated() {
    messengerDialogModule?.input.updateDialog()
  }
  
  public func openNewMessengeScreen(contactAdress: String?) {
    openMessengerNewMessengeScreenModule(contactAdress: contactAdress)
  }
  
  public func openMessengerDialogScreen(dialogModel: ContactModel) {
    openMessengerDialogModule(dialogModel: dialogModel)
  }
}

// MARK: - MessengerDialogScreenModuleOutput

extension MessengerScreenFlowCoordinator: MessengerDialogScreenModuleOutput {
  public func removeDialogMessage(_ message: String?, contact: ContactModel, completion: (() -> Void)?) {
    messengerListScreenModuleModule?.input.removeMessage(message, contact: contact, completion: completion)
  }
  
  public func sendInitiateChatFromDialog(onionAddress: String) {
    messengerListScreenModuleModule?.input.sendInitiateChat(onionAddress: onionAddress)
  }
  
  public func sendMessage(_ message: String, contact: ContactModel) {
    messengerListScreenModuleModule?.input.sendMessage(message, contact: contact)
  }
  
  public func contactHasBeenDeleted(_ contactModel: ContactModel) {
    messengerListScreenModuleModule?.input.removeContactModels(contactModel, completion: { [weak self] in
      guard let self else { return }
      navigationController?.popViewController(animated: true)
    })
  }
  
  public func messengerDialogWillDisappear() {
    messengerListScreenModuleModule?.input.updateListContacts(completion: {})
  }
  
  public func deleteContactButtonTapped() {
    showAlertDeleteContact()
  }
}

// MARK: - MessengerNewMessengeScreenModuleOutput

extension MessengerScreenFlowCoordinator: MessengerNewMessengeScreenModuleOutput {
  public func sendInitiateChatFromNewMessenge(onionAddress: String) {
    messengerListScreenModuleModule?.input.sendInitiateChat(onionAddress: onionAddress)
    messengerNewMessengeScreenModule?.viewController.dismiss(
      animated: true,
      completion: { [weak self] in
        guard let self else { return }
        getContactModel(onionAddress: onionAddress) { [weak self] contactModel in
          guard let self, let contactModel else { return }
          openMessengerDialogModule(dialogModel: contactModel)
        }
        messengerNewMessengeScreenModule = nil
      }
    )
  }
  
  public func closeNewMessengeScreenButtonTapped() {
    messengerListScreenModuleModule?.input.updateListContacts(completion: nil)
    messengerNewMessengeScreenModule?.viewController.dismiss(animated: true)
    messengerNewMessengeScreenModule = nil
  }
}

// MARK: - Open modules

private extension MessengerScreenFlowCoordinator {
  func openMessengerDialogModule(dialogModel: ContactModel) {
    var messengerDialogModule = MessengerDialogScreenAssembly().createModule(
      dialogModel: dialogModel,
      services: services
    )
    self.messengerDialogModule = messengerDialogModule
    messengerDialogModule.input.moduleOutput = self
    
    messengerDialogModule.viewController.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(messengerDialogModule.viewController, animated: true)
  }
  
  func openMessengerNewMessengeScreenModule(contactAdress: String?) {
    var messengerNewMessengeScreenModule = MessengerNewMessengeScreenAssembly()
      .createModule(services: services, contactAdress: contactAdress)
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
  
  func showAlertDeleteContact() {
    UIViewController.topController?.showAlertWithTwoButtons(
      title: "Вы хотите удалить контакт?",
      cancelButtonText: "Отмена",
      customButtonText: "Удалить",
      customButtonAction: { [weak self] in
        self?.messengerDialogModule?.input.userChoseToDeleteContact()
      }
    )
  }
  
  func getContactModel(onionAddress: String, completion: ((ContactModel?) -> Void)?) {
    guard attemptGetContactModel <= 10 else {
      completion?(nil)
      return
    }
    
    messengerListScreenModuleModule?.input.getContactModelsFrom(
      onionAddress: onionAddress,
      completion: { [weak self] contactModel in
        guard let self else { return }
        if let contactModel {
          completion?(contactModel)
        } else {
          attemptGetContactModel += 1
          getContactModel(onionAddress: onionAddress, completion: completion)
        }
      })
  }
  
}
