//
//  RootCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 16.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKAbstractions
import SKStyle
import UIKit
import AuthenticationSDK
import MessengerSDK

final class RootCoordinator: Coordinator<Void, Void> {
  
  // MARK: - Private variables
  
  private var services: IApplicationServices
  
  private var mainFlowCoordinator: MainFlowCoordinator?
  private var initialFlowCoordinator: InitialFlowCoordinator?
  private var authenticationFlowCoordinator: AuthenticationFlowCoordinator?
  
  private lazy var p2pChatManager: IP2PChatManager = services.messengerService.p2pChatManager
  private var notificationService: INotificationService {
    services.userInterfaceAndExperienceService.notificationService
  }
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы приложения
  init(_ services: IApplicationServices) {
    self.services = services
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Internal func
  
  override func start(parameter: Void) {
    setupLaunchScreen()
    setupSessionService()
  }
}

// MARK: - Open screen

private extension RootCoordinator {
  func openMainFlowCoordinator(isPresentScreenAnimated: Bool) {
    let mainFlowCoordinator = MainFlowCoordinator(services, isPresentScreenAnimated: isPresentScreenAnimated)
    self.mainFlowCoordinator = mainFlowCoordinator
    mainFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .lockOChat:
        self?.openAuthenticationFlowCoordinator(.loginPasscode(.loginFaceID))
      case .deleteOChat:
        self?.openInitialFlowCoordinator(isPresentScreenAnimated: true)
      }
      self?.mainFlowCoordinator = nil
    }
    mainFlowCoordinator.start()
  }
  
  func openInitialFlowCoordinator(isPresentScreenAnimated: Bool) {
    let initialFlowCoordinator = InitialFlowCoordinator(services, isPresentScreenAnimated: isPresentScreenAnimated)
    self.initialFlowCoordinator = initialFlowCoordinator
    initialFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .success:
        self?.openMainFlowCoordinator(isPresentScreenAnimated: true)
      case .failure:
        break
      }
      self?.initialFlowCoordinator = nil
    }
    initialFlowCoordinator.start()
  }
  
  func openAuthenticationFlowCoordinator(_ state: AuthenticationScreenState) {
    let authenticationFlowCoordinator = AuthenticationFlowCoordinator(services)
    self.authenticationFlowCoordinator = authenticationFlowCoordinator
    authenticationFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .success:
        self?.openMainFlowCoordinator(isPresentScreenAnimated: true)
      case .failure:
        break
      }
      self?.authenticationFlowCoordinator = nil
    }
    authenticationFlowCoordinator.start(parameter: state)
  }
}

// MARK: - Private

private extension RootCoordinator {
  func setupSessionService() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    
    var sessionService = services.accessAndSecurityManagementService.sessionService
    sessionService.sessionDidExpireAction = { [weak self] in
      guard let self else {
        return
      }
      
      services.messengerService.modelHandlerService.getAppSettingsModel { [weak self] model in
        DispatchQueue.main.async { [weak self] in
          guard let self, model.appPassword != nil else { return }
          openAuthenticationFlowCoordinator(.loginPasscode(.loginFaceID))
          mainFlowCoordinator = nil
        }
      }
    }
  }
  
  func setupLaunchScreen() {
    guard !isFirstLaunchScreen() else {
      return
    }
    
    services.messengerService.modelHandlerService.getMessengerModel { [weak self] model in
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        
        if model.appSettingsModel.appPassword != nil {
          openAuthenticationFlowCoordinator(.loginPasscode(.loginFaceID))
        } else {
          openMainFlowCoordinator(isPresentScreenAnimated: true)
        }
      }
    }
  }
  
  func sessionCheck() {
    services.messengerService.modelHandlerService.getAppSettingsModel { [weak self] model in
      DispatchQueue.main.async { [weak self] in
        guard let self, model.appPassword != nil else { return }
        if !services.accessAndSecurityManagementService.sessionService.isSessionActive() {
          openAuthenticationFlowCoordinator(.loginPasscode(.loginFaceID))
        }
      }
    }
  }
  
  func isFirstLaunchScreen() -> Bool {
    let defaults = UserDefaults.standard
    let hasLaunchedKey = "HasLaunchedInitialFlow"
    
    // Проверяем, была ли функция уже выполнена
    if !defaults.bool(forKey: hasLaunchedKey) {
      openInitialFlowCoordinator(isPresentScreenAnimated: true)
      // Сохраняем, что функция была выполнена
      defaults.set(true, forKey: hasLaunchedKey)
      return true
    }
    return false
  }
  
  @objc
  func appDidBecomeActive() {
    sessionCheck()
  }
}
