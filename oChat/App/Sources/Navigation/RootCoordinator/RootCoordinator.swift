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
    Task { [weak self] in
      guard let self else { return }
      await setupLaunchScreen()
      await setupSessionService()
    }
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
        self?.openAuthenticationFlowCoordinator(.loginPasscode(.enterPasscode))
      case .exit:
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
    let authenticationFlowCoordinator = AuthenticationFlowCoordinator(services, flowType: .all)
    self.authenticationFlowCoordinator = authenticationFlowCoordinator
    authenticationFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .success:
        self?.openMainFlowCoordinator(isPresentScreenAnimated: true)
      case .successFake:
        Task { @MainActor [weak self] in
          guard let self else { return }
          await services.messengerService.appSettingsManager.setAccessType(.fake)
          openMainFlowCoordinator(isPresentScreenAnimated: true)
        }
      case .failure:
        break
      case .allDataErased:
        Task { @MainActor [weak self] in
          guard let self else { return }
          services.messengerService.modelHandlerService.deleteAllData()
          openInitialFlowCoordinator(isPresentScreenAnimated: true)
        }
      }
      self?.authenticationFlowCoordinator = nil
    }
    authenticationFlowCoordinator.start(parameter: state)
  }
}

// MARK: - Private

private extension RootCoordinator {
  func setupSessionService() async {
    let notificationCenter = NotificationCenter.default
    await notificationCenter.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    
    await MainActor.run { [weak self] in
      guard let self else { return }
      var sessionService = services.accessAndSecurityManagementService.sessionService
      sessionService.sessionDidExpireAction = {
        Task { [weak self] in
          guard let self else { return }
          let model = await services.messengerService.modelHandlerService.getAppSettingsModel()
          guard model.appPassword != nil else { return }
          openAuthenticationFlowCoordinator(.loginPasscode(.enterPasscode))
          mainFlowCoordinator = nil
        }
      }
    }
  }
  
  @MainActor
  func setupLaunchScreen() async {
    let modelHandlerService = services.messengerService.modelHandlerService
    let appSettingsModel = await modelHandlerService.getAppSettingsModel()
    
    if appSettingsModel.accessType == .demo {
      modelHandlerService.deleteAllData()
    }
    
    /// В модельке нет сохраненных данных
    if appSettingsModel.toxStateAsString == nil {
      openInitialFlowCoordinator(isPresentScreenAnimated: true)
    } else {
      if appSettingsModel.appPassword != nil {
        openAuthenticationFlowCoordinator(.loginPasscode(.enterPasscode))
      } else {
        openMainFlowCoordinator(isPresentScreenAnimated: true)
      }
    }
  }
  
  @MainActor
  func sessionCheck() async {
    let model = await services.messengerService.modelHandlerService.getAppSettingsModel()
    if !services.accessAndSecurityManagementService.sessionService.isSessionActive(), model.appPassword != nil {
      openAuthenticationFlowCoordinator(.loginPasscode(.enterPasscode))
    }
  }
  
  @objc
  func appDidBecomeActive() {
    Task { [weak self] in
      guard let self else { return }
      await sessionCheck()
    }
  }
}
