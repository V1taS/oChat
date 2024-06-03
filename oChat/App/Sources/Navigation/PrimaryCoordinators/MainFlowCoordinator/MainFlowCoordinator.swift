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
  
  private var mainScreenFlowCoordinator: MainScreenFlowCoordinator?
  private var activityScreenFlowCoordinator: ActivityScreenFlowCoordinator?
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
    setupMainScreenFlowCoordinator()
    setupActivityScreenFlowCoordinator()
    setupMessengerScreenFlowCoordinator()
    setupSettingsScreenFlowCoordinator()

    tabBarController.viewControllers = [
      createMainScreenTab(),
      createActivityScreenTab(),
      createMessengerScreenTab(),
      createSettingsScreenTab()
    ]
    tabBarController.presentAsRoot(animated: isPresentScreenAnimated)
    services.accessAndSecurityManagementService.sessionService.startSession()
  }
}

// MARK: - MainScreenTab

private extension MainFlowCoordinator {
  func createMainScreenTab() -> UINavigationController {
    guard let navigationController = mainScreenFlowCoordinator?.navigationController else {
      return UINavigationController()
    }
    let tabBarItem = UITabBarItem()
    tabBarItem.title = oChatStrings.MainFlowCoordinatorLocalization
      .Tab.MainScreen.title
    tabBarItem.image = UIImage(systemName: "bitcoinsign.square.fill")
    navigationController.tabBarItem = tabBarItem
    return navigationController
  }
  
  func setupMainScreenFlowCoordinator() {
    let mainScreenFlowCoordinator = MainScreenFlowCoordinator(services)
    self.mainScreenFlowCoordinator = mainScreenFlowCoordinator
    mainScreenFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .exitWallet:
        self?.finishMainFlow(.exitWallet)
      }
      self?.mainScreenFlowCoordinator = nil
    }
    
    mainScreenFlowCoordinator.start()
  }
}

// MARK: - ActivityScreenTab

private extension MainFlowCoordinator {
  func createActivityScreenTab() -> UINavigationController {
    guard let navigationController = activityScreenFlowCoordinator?.navigationController else {
      return UINavigationController()
    }
    let tabBarItem = UITabBarItem()
    tabBarItem.title = oChatStrings.MainFlowCoordinatorLocalization
      .Tab.ActivityScreen.title
    tabBarItem.image = UIImage(systemName: "clock")
    navigationController.tabBarItem = tabBarItem
    return navigationController
  }
  
  func setupActivityScreenFlowCoordinator() {
    let activityScreenFlowCoordinator = ActivityScreenFlowCoordinator(services)
    self.activityScreenFlowCoordinator = activityScreenFlowCoordinator
    activityScreenFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .exitWallet:
        self?.finishMainFlow(.exitWallet)
      }
      self?.activityScreenFlowCoordinator = nil
    }
    
    activityScreenFlowCoordinator.start()
  }
}

// MARK: - MessengerScreenTab

private extension MainFlowCoordinator {
  func createMessengerScreenTab() -> UINavigationController {
    guard let navigationController = messengerScreenFlowCoordinator?.navigationController else {
      return UINavigationController()
    }
    let tabBarItem = UITabBarItem()
    tabBarItem.title = oChatStrings.MainFlowCoordinatorLocalization
      .Tab.MessengerScreen.title
    tabBarItem.image = UIImage(systemName: "message.fill")
    navigationController.tabBarItem = tabBarItem
    return navigationController
  }
  
  func setupMessengerScreenFlowCoordinator() {
    let messengerScreenFlowCoordinator = MessengerScreenFlowCoordinator(services)
    self.messengerScreenFlowCoordinator = messengerScreenFlowCoordinator
    messengerScreenFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .exitWallet:
        self?.finishMainFlow(.exitWallet)
      }
      self?.messengerScreenFlowCoordinator = nil
    }
    
    messengerScreenFlowCoordinator.start()
  }
}

// MARK: - SettingsScreenTab

private extension MainFlowCoordinator {
  func createSettingsScreenTab() -> UINavigationController {
    guard let navigationController = settingsScreenFlowCoordinator?.navigationController else {
      return UINavigationController()
    }
    let tabBarItem = UITabBarItem()
    tabBarItem.title = oChatStrings.MainFlowCoordinatorLocalization
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
      case .exitWallet:
        self?.finishMainFlow(.exitWallet)
      }
      self?.settingsScreenFlowCoordinator = nil
    }
    
    settingsScreenFlowCoordinator.start()
  }
}

// MARK: - Private

private extension MainFlowCoordinator {
  func finishMainFlow(_ flowType: MainFinishFlowType) {
    mainScreenFlowCoordinator = nil
    activityScreenFlowCoordinator = nil
    messengerScreenFlowCoordinator = nil
    settingsScreenFlowCoordinator = nil
    finishFlow?(flowType)
  }
}
