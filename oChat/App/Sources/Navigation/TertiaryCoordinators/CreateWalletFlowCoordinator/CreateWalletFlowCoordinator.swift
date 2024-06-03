//
//  CreateWalletFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

final class CreateWalletFlowCoordinator: Coordinator<CreateWalletFlowType, CreateWalletFinishFlowType> {
  
  // MARK: - Internal variables
  
  let viewController: UIViewController?
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  private var walletFlowType: CreateWalletFlowType?
  
  private var createPhraseWalletScreenModule: CreatePhraseWalletScreenModule?
  private var createHighTechGenerateImageIDScreenModule: HighTechImageIDScreenModule?
  private var createHighTechLoginImageIDScreenModule: HighTechImageIDScreenModule?
  
  private var hintBackupScreenModule: HintBackupScreenModule?
  private var listSeedPhraseScreenModule: ListSeedPhraseScreenModule?
  private var authenticationFlowCoordinator: AuthenticationFlowCoordinator?
  private var suggestAccessCodeScreenModule: SuggestScreenModule?
  private var suggestFaceIDScreenModule: SuggestScreenModule?
  private var suggestNotificationsScreenModule: SuggestScreenModule?
  private var highTechImageIDInfoSheetModule: HighTechImageIDInfoSheetModule?
  private var cacheWalletModel: WalletModel?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - viewController: Основной Вью контроллер
  ///   - services: Сервисы приложения
  init(_ viewController: UIViewController?,
       _ services: IApplicationServices) {
    self.viewController = viewController
    self.services = services
  }
  
  // MARK: - Internal func
  
  override func start(parameter: CreateWalletFlowType) {
    walletFlowType = parameter
    
    switch parameter {
    case .seedPhrase12:
      openPhraseWalletScreenModule(.seedPhrase12)
    case .seedPhrase24:
      openPhraseWalletScreenModule(.seedPhrase24)
    case .highTechImageID:
      openPhraseWalletScreenModule(.seedPhrase24)
    }
  }
}

// MARK: - CreatePhraseWalletScreenModuleOutput

extension CreateWalletFlowCoordinator: CreatePhraseWalletScreenModuleOutput {
  func walletSeedPhraseHasBeenCreated(_ walletModel: WalletModel) {
    cacheWalletModel = walletModel
    
    switch walletFlowType ?? .seedPhrase24 {
    case .seedPhrase12, .seedPhrase24:
      openHintBackupScreenModule(.backupPhrase)
    case .highTechImageID:
      openHintBackupScreenModule(.backupImage)
    }
  }
}

// MARK: - HintBackupScreenModuleOutput

extension CreateWalletFlowCoordinator: HintBackupScreenModuleOutput {
  func continueHintBackupButtonTapped() {
    guard let cacheWalletModel else {
      services.userInterfaceAndExperienceService.notificationService.showNotification(
        .negative(
          title: oChatStrings.CreateWalletFlowCoordinatorLocalization
            .State.SomethingWentWrong.title
        )
      )
      return
    }
    
    switch walletFlowType ?? .seedPhrase24 {
    case .seedPhrase12, .seedPhrase24:
      openListSeedPhraseScreenModule(cacheWalletModel)
    case .highTechImageID:
      openHighTechGenerateImageIDScreenModule(cacheWalletModel)
    }
  }
}

// MARK: - ListSeedPhraseScreenModuleOutput

extension CreateWalletFlowCoordinator: ListSeedPhraseScreenModuleOutput {
  func closeListSeedScreenButtonTapped() {
    finishCreateWalletFlow(.failure)
  }
  
  func saveListSeedAndContinueButtonTapped() {
    services.dataManagementService.modelHandlerService.getAppSettingsModel { [weak self] appSettingsModel in
      guard let self else {
        return
      }
      if appSettingsModel.appPassword == nil {
        openSuggestAccessCodeScreenModule()
      } else if !appSettingsModel.isNotificationsEnabled {
        openSuggestNotificationsScreenModule()
      } else {
        finishCreateWalletFlow(.success)
      }
    }
  }
}

// MARK: - SuggestScreenModuleOutput

extension CreateWalletFlowCoordinator: SuggestScreenModuleOutput {
  func skipSuggestAccessCodeScreenButtonTapped(_ isNotifications: Bool) {
    switch isNotifications {
    case true:
      finishCreateWalletFlow(.success)
    case false:
      openSuggestNotificationsScreenModule()
    }
  }
  
  func skipSuggestNotificationsScreenButtonTapped() {
    finishCreateWalletFlow(.success)
  }
  
  func suggestAccessCodeScreenConfirmButtonTapped() {
    openAuthenticationFlow(.createPasscode(.enterPasscode))
  }
  
  func suggestFaceIDScreenConfirmButtonTapped(_ isEnabledNotifications: Bool) {
    switch isEnabledNotifications {
    case true:
      finishCreateWalletFlow(.success)
    case false:
      openSuggestNotificationsScreenModule()
    }
  }
  
  func suggestNotificationScreenConfirmButtonTapped() {
    finishCreateWalletFlow(.success)
  }
}

// MARK: - HighTechImageIDScreenModuleOutput

extension CreateWalletFlowCoordinator: HighTechImageIDScreenModuleOutput {
  func closeButtonHighTechImageIDScreenTapped() {
    finishCreateWalletFlow(.failure)
  }
  
  func openInfoImageIDSheet() {
    openHighTechImageIDInfoSheetModule()
  }
  
  func saveHighTechImageIDToGallery(_ image: Data?) {
    services.accessAndSecurityManagementService.permissionService.requestGallery { [weak self] granted in
      switch granted {
      case true:
        self?.services.userInterfaceAndExperienceService.uiService.saveImageToGallery(image, completion: { isSuccess in
          switch isSuccess {
          case true:
            self?.services.userInterfaceAndExperienceService.notificationService.showNotification(
              .positive(
                title: oChatStrings.CreateWalletFlowCoordinatorLocalization.State.SaveHighTechImageID.success
              )
            )
          case false:
            self?.services.userInterfaceAndExperienceService.notificationService.showNotification(
              .negative(
                title: oChatStrings.CreateWalletFlowCoordinatorLocalization.State.SaveHighTechImageID.failure
              )
            )
          }
        })
      case false:
        self?.services.userInterfaceAndExperienceService.notificationService.showNotification(
          .negative(
            title: oChatStrings.CreateWalletFlowCoordinatorLocalization.State.PermissionGallery.failure
          ),
          action: { [weak self] in
            self?.services.userInterfaceAndExperienceService.systemService.openSettings()
          }
        )
      }
    }
  }
  
  func successCreatedHighTechImageIDScreen() {
    openHighTechLoginImageIDScreenModule()
  }
  
  func successLoginHighTechImageIDScreen() {
    services.dataManagementService.modelHandlerService.getAppSettingsModel { [weak self] appSettingsModel in
      guard let self else {
        return
      }
      if appSettingsModel.appPassword == nil {
        openSuggestAccessCodeScreenModule()
      } else if !appSettingsModel.isNotificationsEnabled {
        openSuggestNotificationsScreenModule()
      } else {
        finishCreateWalletFlow(.success)
      }
    }
  }
}

// MARK: - HighTechImageIDInfoSheetModuleOutput

extension CreateWalletFlowCoordinator: HighTechImageIDInfoSheetModuleOutput {}

// MARK: - Open modules

private extension CreateWalletFlowCoordinator {
  func openPhraseWalletScreenModule(_ walletType: CreatePhraseWalletScreenType) {
    var createPhraseWalletScreenModule = CreatePhraseWalletScreenAssembly().createModule(walletType, services)
    self.createPhraseWalletScreenModule = createPhraseWalletScreenModule
    createPhraseWalletScreenModule.input.moduleOutput = self
    
    viewController?.presentFullScreen(createPhraseWalletScreenModule.viewController)
  }
  
  func openHintBackupScreenModule(_ hintType: HintBackupScreenType) {
    var hintBackupScreenModule = HintBackupScreenAssembly().createModule(hintType)
    self.hintBackupScreenModule = hintBackupScreenModule
    hintBackupScreenModule.input.moduleOutput = self
    UIViewController.topController?.presentFullScreen(
      hintBackupScreenModule.viewController.wrapToNavigationController(),
      animated: false
    )
  }
  
  func openListSeedPhraseScreenModule(_ walletModel: WalletModel) {
    var listSeedPhraseScreenModule = ListSeedPhraseScreenAssembly().createModule(
      services: services,
      screenType: .termsAndConditionsScreen,
      walletModel: walletModel
    )
    self.listSeedPhraseScreenModule = listSeedPhraseScreenModule
    listSeedPhraseScreenModule.input.moduleOutput = self
    UIViewController.topController?.presentFullScreen(
      listSeedPhraseScreenModule.viewController.wrapToNavigationController(),
      animated: false
    )
  }
  
  func openHighTechGenerateImageIDScreenModule(_ walletModel: WalletModel) {
    var createHighTechGenerateImageIDScreenModule = HighTechImageIDScreenAssembly().createModule(
      state: .generateImageID(.initialState),
      services: services,
      walletModel: walletModel
    )
    self.createHighTechGenerateImageIDScreenModule = createHighTechGenerateImageIDScreenModule
    createHighTechGenerateImageIDScreenModule.input.moduleOutput = self
    UIViewController.topController?.presentFullScreen(
      createHighTechGenerateImageIDScreenModule.viewController.wrapToNavigationController(),
      animated: false
    )
  }
  
  func openHighTechLoginImageIDScreenModule() {
    var createHighTechLoginImageIDScreenModule = HighTechImageIDScreenAssembly().createModule(
      state: .loginImageID(.initialState),
      services: services,
      walletModel: nil
    )
    self.createHighTechLoginImageIDScreenModule = createHighTechLoginImageIDScreenModule
    createHighTechLoginImageIDScreenModule.input.moduleOutput = self
    UIViewController.topController?.presentFullScreen(
      createHighTechLoginImageIDScreenModule.viewController.wrapToNavigationController(),
      animated: false
    )
  }
  
  func openSuggestAccessCodeScreenModule() {
    var suggestAccessCodeScreenModule = SuggestScreenAssembly().createModule(.setAccessCode, services: services)
    self.suggestAccessCodeScreenModule = suggestAccessCodeScreenModule
    suggestAccessCodeScreenModule.input.moduleOutput = self
    
    UIViewController.topController?.presentFullScreen(
      suggestAccessCodeScreenModule.viewController.wrapToNavigationController(),
      animated: false
    )
  }
  
  func openSuggestFaceIDScreenModule() {
    var suggestFaceIDScreenModule = SuggestScreenAssembly().createModule(.setFaceID, services: services)
    self.suggestFaceIDScreenModule = suggestFaceIDScreenModule
    suggestFaceIDScreenModule.input.moduleOutput = self
    
    UIViewController.topController?.presentFullScreen(
      suggestFaceIDScreenModule.viewController.wrapToNavigationController(),
      animated: false
    )
  }
  
  func openSuggestNotificationsScreenModule() {
    var suggestNotificationsScreenModule = SuggestScreenAssembly().createModule(.setNotifications, services: services)
    self.suggestNotificationsScreenModule = suggestNotificationsScreenModule
    suggestNotificationsScreenModule.input.moduleOutput = self
    
    UIViewController.topController?.presentFullScreen(
      suggestNotificationsScreenModule.viewController.wrapToNavigationController(),
      animated: false
    )
  }
  
  func openHighTechImageIDInfoSheetModule() {
    var highTechImageIDInfoSheetModule = HighTechImageIDInfoSheetAssembly().createModule()
    self.highTechImageIDInfoSheetModule = highTechImageIDInfoSheetModule
    highTechImageIDInfoSheetModule.input.moduleOutput = self
    
    UIViewController.topController?.presentBottomSheet(
      highTechImageIDInfoSheetModule.viewController,
      targetHeight: Constants.targetHeight
    )
  }
  
  func openAuthenticationFlow(_ state: AuthenticationScreenState) {
    let authenticationFlowCoordinator = AuthenticationFlowCoordinator(
      services,
      viewController: UIViewController.topController,
      openType: .push
    )
    self.authenticationFlowCoordinator = authenticationFlowCoordinator
    
    authenticationFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .success:
        self?.openSuggestFaceIDScreenModule()
      case .failure:
        break
      }
      self?.authenticationFlowCoordinator = nil
    }
    
    authenticationFlowCoordinator.start(parameter: state)
  }
}

// MARK: - Private

private extension CreateWalletFlowCoordinator {
  func finishCreateWalletFlow(_ type: CreateWalletFinishFlowType) {
    createPhraseWalletScreenModule = nil
    createHighTechGenerateImageIDScreenModule = nil
    createHighTechLoginImageIDScreenModule = nil
    hintBackupScreenModule = nil
    listSeedPhraseScreenModule = nil
    authenticationFlowCoordinator = nil
    suggestAccessCodeScreenModule = nil
    suggestFaceIDScreenModule = nil
    suggestNotificationsScreenModule = nil
    highTechImageIDInfoSheetModule = nil
    finishFlow?(type)
  }
}

// MARK: - Constants

private enum Constants {
  static let targetHeight: CGFloat = 350
}
