//
//  SettingsScreenFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit
import AuthenticationSDK
import MessengerSDK

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
  private var messengerProfileModule: MessengerProfileModule?
  private var mailComposeModule: MailComposeModule?
  
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
  func userSelectFeedBack() {
    openMailModule()
  }
  
  func openMyProfileSection() {
    openMessengerProfileModule()
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
      title: OChatStrings.SettingsScreenFlowCoordinatorLocalization
        .LanguageSection.Alert.title,
      cancelButtonText: OChatStrings.SettingsScreenFlowCoordinatorLocalization
        .LanguageSection.Alert.CancelButton.title,
      customButtonText: OChatStrings.SettingsScreenFlowCoordinatorLocalization
        .LanguageSection.Alert.CustomButton.title,
      customButtonAction: { [weak self] in
        Task { [weak self] in
          await self?.services.userInterfaceAndExperienceService.systemService.openSettings()
        }
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
      Task { [weak self] in
        await self?.passcodeSettingsScreenModule?.input.successAuthorizationPasswordDisable()
      }
    }
  }
  
  func openNewAccessCode() {
    openAuthenticationFlow(state: .createPasscode(.enterPasscode)) { [weak self] in
      Task { [weak self] in
        await self?.passcodeSettingsScreenModule?.input.updateScreen()
      }
      
      Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
        self?.services.userInterfaceAndExperienceService.notificationService.showNotification(
          .positive(
            title: OChatStrings.SettingsScreenFlowCoordinatorLocalization
              .State.Notification.NewAccessCode.success
          )
        )
      }
    }
  }
  
  func openChangeAccessCode() {
    openAuthenticationFlow(state: .changePasscode(.enterOldPasscode)) { [weak self] in
      Task { [weak self] in
        await self?.passcodeSettingsScreenModule?.input.updateScreen()
      }
      
      Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
        self?.services.userInterfaceAndExperienceService.notificationService.showNotification(
          .positive(
            title: OChatStrings.SettingsScreenFlowCoordinatorLocalization
              .State.Notification.ChangePassCode.success
          )
        )
      }
    }
  }
}

// MARK: - MessengerProfileModuleModuleOutput

extension SettingsScreenFlowCoordinator: MessengerProfileModuleModuleOutput {
  func closeMessengerProfileScreenTapped() {
    navigationController?.popViewController(animated: true)
  }
  
  func shareQRMessengerProfileScreenTapped(_ image: UIImage?, name: String) {
    shareButtonAction(image: image, name: name)
  }
}

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
  
  func openMessengerProfileModule() {
    var messengerProfileModule = MessengerProfileModuleAssembly().createModule(services: services)
    self.messengerProfileModule = messengerProfileModule
    messengerProfileModule.input.moduleOutput = self
    
    messengerProfileModule.viewController.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(
      messengerProfileModule.viewController,
      animated: true
    )
  }
  
  func openMailModule() {
    let mailComposeModule = MailComposeModule(services)
    self.mailComposeModule = mailComposeModule
    
    guard mailComposeModule.canSendMail() else {
      services.userInterfaceAndExperienceService
        .notificationService.showNotification(
          .negative(
            title: "Почтовый клиент не найден"
          )
        )
      return
    }
    
    mailComposeModule.start(completion: { [weak self] in
      self?.mailComposeModule = nil
    })
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
    messengerProfileModule = nil
    finishFlow?(flowType)
  }
  
  func shareButtonAction(image: UIImage?, name: String) {
    guard let image,
          let imageData = image.jpegData(compressionQuality: 0.1),
          let imageFile = services.dataManagementService.dataManagerService.saveObjectWith(
            fileName: name,
            fileExtension: ".jpg",
            data: imageData
          ) else {
      return
    }
    
    let activityViewController = UIActivityViewController(activityItems: [imageFile],
                                                          applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = messengerProfileModule?.viewController.view
    activityViewController.excludedActivityTypes = [
      UIActivity.ActivityType.airDrop,
      UIActivity.ActivityType.postToFacebook,
      UIActivity.ActivityType.message,
      UIActivity.ActivityType.addToReadingList,
      UIActivity.ActivityType.assignToContact,
      UIActivity.ActivityType.copyToPasteboard,
      UIActivity.ActivityType.markupAsPDF,
      UIActivity.ActivityType.openInIBooks,
      UIActivity.ActivityType.postToFlickr,
      UIActivity.ActivityType.postToTencentWeibo,
      UIActivity.ActivityType.postToTwitter,
      UIActivity.ActivityType.postToVimeo,
      UIActivity.ActivityType.postToWeibo,
      UIActivity.ActivityType.print
    ]
    
    if UIDevice.current.userInterfaceIdiom == .pad {
      if let popup = activityViewController.popoverPresentationController {
        popup.sourceView = messengerProfileModule?.viewController.view
        popup.sourceRect = CGRect(
          x: (
            messengerProfileModule?.viewController.view.frame.size.width ?? .zero
          ) / 2,
          y: (
            messengerProfileModule?.viewController.view.frame.size.height ?? .zero
          ) / 4,
          width: .zero,
          height: .zero
        )
      }
    }
    
    messengerProfileModule?.viewController.present(
      activityViewController,
      animated: true,
      completion: {
        [weak self] in
        Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { [weak self] _ in
          self?.services.dataManagementService.dataManagerService.deleteObjectWith(
            fileURL: imageFile,
            isRemoved: {
              _ in
            }
          )
        }
      }
    )
  }
}
