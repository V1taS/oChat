//
//  MainFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 16.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

final class MainFlowCoordinator: Coordinator<Void, MainFinishFlowType> {
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  private let tabBarController = UITabBarController()
  private let isPresentScreenAnimated: Bool
  
  private var messengerScreenFlowCoordinator: MessengerScreenFlowCoordinator?
  private var settingsScreenFlowCoordinator: SettingsScreenFlowCoordinator?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы приложения
  ///   - isPresentScreenAnimated: Анимированный показ экрана
  init(_ services: IApplicationServices,
       isPresentScreenAnimated: Bool) {
    self.services = services
    self.isPresentScreenAnimated = isPresentScreenAnimated
  }
  
  // MARK: - Internal func
  
  override func start(parameter: Void) {
    Task { @MainActor [weak self] in
      guard let self else { return }
      let accessType = await services.messengerService.modelHandlerService.getAppSettingsModel().accessType
      setupMessengerScreenFlowCoordinator(accessType: accessType)
      setupSettingsScreenFlowCoordinator()

      tabBarController.viewControllers = [
        createMessengerScreenTab(),
        createSettingsScreenTab()
      ]
      tabBarController.presentAsRoot(animated: isPresentScreenAnimated)
      services.accessAndSecurityManagementService.sessionService.startSession()
    }
  }
}

// MARK: - MessengerScreenTab

private extension MainFlowCoordinator {
  func createMessengerScreenTab() -> UINavigationController {
    guard let navigationController = messengerScreenFlowCoordinator?.navigationController else {
      return UINavigationController()
    }
    let tabBarItem = UITabBarItem()
    tabBarItem.title = OChatStrings.MainFlowCoordinatorLocalization
      .Tab.MessengerScreen.title
    tabBarItem.image = UIImage(systemName: "message.fill")
    navigationController.tabBarItem = tabBarItem
    return navigationController
  }
  
  func setupMessengerScreenFlowCoordinator(accessType: AppSettingsModel.AccessType) {
    let messengerScreenFlowCoordinator = MessengerScreenFlowCoordinator(services)
    self.messengerScreenFlowCoordinator = messengerScreenFlowCoordinator
    messengerScreenFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .lockOChat:
        self?.finishMainFlow(.lockOChat)
      case .exit:
        self?.finishMainFlow(.exit)
      }
      self?.messengerScreenFlowCoordinator = nil
    }
    
    messengerScreenFlowCoordinator.start(parameter: accessType)
  }
}

// MARK: - SettingsScreenTab

private extension MainFlowCoordinator {
  func createSettingsScreenTab() -> UINavigationController {
    guard let navigationController = settingsScreenFlowCoordinator?.navigationController else {
      return UINavigationController()
    }
    let tabBarItem = UITabBarItem()
    tabBarItem.title = OChatStrings.MainFlowCoordinatorLocalization
      .Tab.SettingsScreen.title
    tabBarItem.image = UIImage(systemName: "gear")
    navigationController.tabBarItem = tabBarItem
    return navigationController
  }
  
  func setupSettingsScreenFlowCoordinator() {
    let settingsScreenFlowCoordinator = SettingsScreenFlowCoordinator(services)
    self.settingsScreenFlowCoordinator = settingsScreenFlowCoordinator
    settingsScreenFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .lockOChat:
        self?.finishMainFlow(.lockOChat)
      case .exit:
        self?.finishMainFlow(.exit)
      }
      self?.settingsScreenFlowCoordinator = nil
    }
    
    settingsScreenFlowCoordinator.start()
  }
}

// MARK: - Private

private extension MainFlowCoordinator {
  func finishMainFlow(_ flowType: MainFinishFlowType) {
    messengerScreenFlowCoordinator = nil
    settingsScreenFlowCoordinator = nil
    finishFlow?(flowType)
  }
}
