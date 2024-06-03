//
//  SettingsScreenFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

final class SettingsScreenFlowCoordinator: Coordinator<Void, SettingsScreenFinishFlowType> {
  
  // MARK: - Internal variables
  
  var navigationController: UINavigationController?
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  
  private var settingsScreenModule: SettingsScreenModule?
  private var appearanceAppScreenModule: AppearanceAppScreenModule?
  private var notificationsSettingsScreenModule: NotificationsSettingsScreenModule?
  private var passcodeSettingsScreenModule: PasscodeSettingsScreenModule?
  private var authenticationFlowCoordinator: AuthenticationFlowCoordinator?
  private var currencyListScreenModule: CurrencyListScreenModule?
  private var myWalletsFlowCoordinator: MyWalletsFlowCoordinator?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы приложения
  init(_ services: IApplicationServices) {
    self.services = services
  }
  
  // MARK: - Internal func
  
  override func start(parameter: Void) {
    openSettingsScreenModule()
  }
}

// MARK: - MainScreenModuleOutput

extension SettingsScreenFlowCoordinator: SettingsScreenModuleOutput {
  func openMessengerSection() {}
  
  func openMyWalletsSection() {
    openMyWalletsFlow()
  }
  
  func openCurrencySection() {
    openCurrencyListScreenModule()
  }
  
  func openPasscodeAndFaceIDSection() {
    openPasscodeSettingsScreenModule()
  }
  
  func openNotificationsSection() {
    openNotificationsSettingsScreenModule()
  }
  
  func openAppearanceSection() {
    openAppearanceAppScreenModule()
  }
  
  func openLanguageSection() {
    UIViewController.topController?.showAlertWithTwoButtons(
      title: oChatStrings.SettingsScreenFlowCoordinatorLocalization
        .LanguageSection.Alert.title,
      cancelButtonText: oChatStrings.SettingsScreenFlowCoordinatorLocalization
        .LanguageSection.Alert.CancelButton.title,
      customButtonText: oChatStrings.SettingsScreenFlowCoordinatorLocalization
        .LanguageSection.Alert.CustomButton.title,
      customButtonAction: { [weak self] in
        self?.services.userInterfaceAndExperienceService.systemService.openSettings()
      }
    )
  }
}

// MARK: - AppearanceAppScreenModuleOutput

extension SettingsScreenFlowCoordinator: AppearanceAppScreenModuleOutput {}

// MARK: - NotificationsSettingsScreenModuleOutput

extension SettingsScreenFlowCoordinator: NotificationsSettingsScreenModuleOutput {}

// MARK: - PasscodeSettingsScreenModuleOutput

extension SettingsScreenFlowCoordinator: PasscodeSettingsScreenModuleOutput {
  func openAuthorizationPasswordDisable() {
    openAuthenticationFlow(state: .loginPasscode(.loginFaceID)) { [weak self] in
      self?.passcodeSettingsScreenModule?.input.successAuthorizationPasswordDisable()
    }
  }
  
  func openNewAccessCode() {
    openAuthenticationFlow(state: .createPasscode(.enterPasscode)) { [weak self] in
      self?.passcodeSettingsScreenModule?.input.updateScreen()
      Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
        self?.services.userInterfaceAndExperienceService.notificationService.showNotification(
          .positive(
            title: oChatStrings.SettingsScreenFlowCoordinatorLocalization
              .State.Notification.NewAccessCode.success
          )
        )
      }
    }
  }
  
  func openChangeAccessCode() {
    openAuthenticationFlow(state: .changePasscode(.enterOldPasscode)) { [weak self] in
      self?.passcodeSettingsScreenModule?.input.updateScreen()
      Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
        self?.services.userInterfaceAndExperienceService.notificationService.showNotification(
          .positive(
            title: oChatStrings.SettingsScreenFlowCoordinatorLocalization
              .State.Notification.ChangePassCode.success
          )
        )
      }
    }
  }
}

// MARK: - CurrencyListScreenModuleOutput

extension SettingsScreenFlowCoordinator: CurrencyListScreenModuleOutput {}

// MARK: - Open modules

private extension SettingsScreenFlowCoordinator {
  func openSettingsScreenModule() {
    var settingsScreenModule = SettingsScreenAssembly().createModule(services)
    self.settingsScreenModule = settingsScreenModule
    settingsScreenModule.input.moduleOutput = self
    navigationController = settingsScreenModule.viewController.wrapToNavigationController()
  }
  
  func openAppearanceAppScreenModule() {
    var appearanceAppScreenModule = AppearanceAppScreenAssembly().createModule(services)
    self.appearanceAppScreenModule = appearanceAppScreenModule
    appearanceAppScreenModule.input.moduleOutput = self
    appearanceAppScreenModule.viewController.hidesBottomBarWhenPushed = true
    
    navigationController?.pushViewController(
      appearanceAppScreenModule.viewController,
      animated: true
    )
  }
  
  func openNotificationsSettingsScreenModule() {
    var notificationsSettingsScreenModule = NotificationsSettingsScreenAssembly().createModule(services)
    self.notificationsSettingsScreenModule = notificationsSettingsScreenModule
    notificationsSettingsScreenModule.input.moduleOutput = self
    notificationsSettingsScreenModule.viewController.hidesBottomBarWhenPushed = true
    
    navigationController?.pushViewController(
      notificationsSettingsScreenModule.viewController,
      animated: true
    )
  }
  
  func openPasscodeSettingsScreenModule() {
    var passcodeSettingsScreenModule = PasscodeSettingsScreenAssembly().createModule(services)
    self.passcodeSettingsScreenModule = passcodeSettingsScreenModule
    passcodeSettingsScreenModule.input.moduleOutput = self
    passcodeSettingsScreenModule.viewController.hidesBottomBarWhenPushed = true
    
    navigationController?.pushViewController(
      passcodeSettingsScreenModule.viewController,
      animated: true
    )
  }
  
  func openAuthenticationFlow(
    state: AuthenticationScreenState,
    completion: (() -> Void)?
  ) {
    let authenticationFlowCoordinator = AuthenticationFlowCoordinator(
      services,
      viewController: navigationController,
      openType: .push
    )
    self.authenticationFlowCoordinator = authenticationFlowCoordinator
    authenticationFlowCoordinator.finishFlow = { [weak self] state in
      guard let self else {
        return
      }
      switch state {
      case .success:
        completion?()
        navigationController?.popViewController(animated: true)
      case .failure:
        break
      }
      self.authenticationFlowCoordinator = nil
    }
    authenticationFlowCoordinator.start(parameter: state)
  }
  
  func openCurrencyListScreenModule() {
    var currencyListScreenModule = CurrencyListScreenAssembly().createModule(services)
    self.currencyListScreenModule = currencyListScreenModule
    currencyListScreenModule.input.moduleOutput = self
    currencyListScreenModule.viewController.hidesBottomBarWhenPushed = true
    
    navigationController?.pushViewController(
      currencyListScreenModule.viewController,
      animated: true
    )
  }
  
  func openMyWalletsFlow() {
    let myWalletsFlowCoordinator = MyWalletsFlowCoordinator(
      navigationController,
      services
    )
    self.myWalletsFlowCoordinator = myWalletsFlowCoordinator

    myWalletsFlowCoordinator.finishFlow = { [weak self] result in
      if case .exitTheApplication = result {
        self?.finishSettingsScreenFlow(.exitWallet)
      }
      self?.myWalletsFlowCoordinator = nil
    }
    myWalletsFlowCoordinator.start()
  }
}

// MARK: - Private

private extension SettingsScreenFlowCoordinator {
  func finishSettingsScreenFlow(_ flowType: SettingsScreenFinishFlowType) {
    settingsScreenModule = nil
    appearanceAppScreenModule = nil
    notificationsSettingsScreenModule = nil
    passcodeSettingsScreenModule = nil
    authenticationFlowCoordinator = nil
    currencyListScreenModule = nil
    myWalletsFlowCoordinator = nil
    finishFlow?(flowType)
  }
}
