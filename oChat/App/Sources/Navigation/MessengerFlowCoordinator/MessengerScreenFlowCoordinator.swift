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
  
  private let services: IApplicationServices
  private var messengerListScreenModuleModule: MessengerListScreenModuleModule?
  private var messengerDialogModule: MessengerDialogScreenModule?
  
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
  public func handleFileSender(progress: Int, publicToxKey: String) {
    messengerDialogModule?.input.handleFileSender(progress: progress, publicToxKey: publicToxKey)
  }
  
  public func handleFileReceive(progress: Int, publicToxKey: String) {
    messengerDialogModule?.input.handleFileReceive(progress: progress, publicToxKey: publicToxKey)
  }
  
  public func openPanelConnection() {
    // TODO: - 🟡
  }
  
  public func openNewMessengeScreen(contactAdress: String?) {
    openMessengerDialogModule(dialogModel: nil, contactAdress: contactAdress)
  }
  
  public func dataModelHasBeenUpdated() {
    messengerDialogModule?.input.updateDialog()
  }
  
  public func openMessengerDialogScreen(dialogModel: ContactModel) {
    openMessengerDialogModule(dialogModel: dialogModel)
  }
}

// MARK: - MessengerDialogScreenModuleOutput

extension MessengerScreenFlowCoordinator: MessengerDialogScreenModuleOutput {
  public func sendPushNotification(contact: ContactModel) async {
    guard let module = messengerListScreenModuleModule?.input else {
      return
    }
    
    await module.sendPushNotification(contact: contact)
  }
  
  public func setUserIsTyping(
    _ isTyping: Bool,
    to toxPublicKey: String
  ) async -> Result<Void, any Error> {
    guard let module = messengerListScreenModuleModule?.input else {
      return .failure(URLError(.unknown))
    }
    return await module.setUserIsTyping(
      isTyping,
      to: toxPublicKey
    )
  }
  
  public func closeMessengerDialog() {
    navigationController?.popViewController(animated: true)
    messengerDialogModule = nil
  }
  
  public func saveContactModel(_ model: ContactModel) async {
    guard let module = messengerListScreenModuleModule?.input else {
      return
    }
    
    await module.saveContactModel(model)
  }
  
  public func removeMessage(id: String, contact: ContactModel) async {
    guard let module = messengerListScreenModuleModule?.input else {
      return
    }
    
    await module.removeMessage(id: id, contact: contact)
  }
  
  public func confirmRequestForDialog(contactModel: ContactModel) async {
    guard let module = messengerListScreenModuleModule?.input else {
      return
    }
    
    await module.confirmRequestForDialog(contactModel: contactModel)
  }
  
  public func cancelRequestForDialog(contactModel: ContactModel) async {
    guard let module = messengerListScreenModuleModule?.input else {
      return
    }
    
    await module.cancelRequestForDialog(contactModel: contactModel)
  }
  
  public func sendInitiateChatFromDialog(contactModel: ContactModel) async {
    guard let module = messengerListScreenModuleModule?.input else {
      return
    }
    
    await module.sendInitiateChat(contactModel: contactModel)
  }
  
  public func sendMessage(contact: ContactModel) async {
    guard let module = messengerListScreenModuleModule?.input else {
      return
    }
    
    await module.sendMessage(contact: contact)
  }
  
  public func messengerDialogWillDisappear() async {
    guard let module = messengerListScreenModuleModule?.input else {
      return
    }
    
    await module.updateListContacts()
  }
}

// MARK: - Open modules

private extension MessengerScreenFlowCoordinator {
  func openMessengerDialogModule(dialogModel: ContactModel?, contactAdress: String? = nil) {
    var messengerDialogModule = MessengerDialogScreenAssembly().createModule(
      dialogModel: dialogModel,
      contactAdress: contactAdress,
      services: services
    )
    self.messengerDialogModule = messengerDialogModule
    messengerDialogModule.input.moduleOutput = self
    
    messengerDialogModule.viewController.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(messengerDialogModule.viewController, animated: true)
  }
}

// MARK: - Private

private extension MessengerScreenFlowCoordinator {
  func finishMessengerFlow(_ flowType: MessengerScreenFinishFlowType) {
    messengerListScreenModuleModule = nil
    messengerDialogModule = nil
    finishFlow?(flowType)
  }
}
