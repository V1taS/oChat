//
//  MyWalletsFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

final class MyWalletsFlowCoordinator: Coordinator<Void, MyWalletsFinishFlowType> {
  
  // MARK: - Internal variables
  
  let navigationController: UINavigationController?
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  
  private var myWalletsScreenModule: MyWalletsScreenModule?
  private var myWalletSettingsScreenModule: MyWalletSettingsScreenModule?
  private var myNewWalletSheetModule: MyNewWalletSheetModule?
  private var createWalletFlowCoordinator: CreateWalletFlowCoordinator?
  private var restoreWalletFlowCoordinator: RestoreWalletFlowCoordinator?
  private var removeWalletSheetModule: RemoveWalletSheetModule?
  private var listSeedPhraseScreenModule: ListSeedPhraseScreenModule?
  private var authenticationFlowCoordinator: AuthenticationFlowCoordinator?
  private var myWalletCustomizationScreenModule: MyWalletCustomizationScreenModule?
  private var saveImageScreenModule: SaveImageScreenModule?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - navigationController: Основной Навигейшен вью контроллер
  ///   - services: Сервисы приложения
  init(_ navigationController: UINavigationController?,
       _ services: IApplicationServices) {
    self.navigationController = navigationController
    self.services = services
  }
  
  // MARK: - Internal func
  
  override func start(parameter: Void) {
    openMyWalletsScreenModule()
  }
}

// MARK: - MyWalletsScreenModuleOutput

extension MyWalletsFlowCoordinator: MyWalletsScreenModuleOutput {
  func openMyWalletSettingsScreen(_ walletModel: WalletModel) {
    openMyWalletSettingsScreenModule(walletModel)
  }
  
  func openAddNewWalletSheet() {
    openMyNewWalletSheetModule()
  }
}

// MARK: - MyWalletSettingsScreenModuleOutput

extension MyWalletsFlowCoordinator: MyWalletSettingsScreenModuleOutput {
  func openRecoveryImageIDScreen(_ walletModel: SKAbstractions.WalletModel) {
    services.dataManagementService.modelHandlerService.getAppSettingsModel { [weak self] appSettingsModel in
      if appSettingsModel.appPassword == nil {
        self?.openSaveImageScreenModule(walletModel, animated: true)
      } else {
        self?.openAuthenticationFlow { [weak self] in
          self?.openSaveImageScreenModule(walletModel, animated: false)
        }
      }
    }
  }
  
  func walletSuccessfullyDeleted() {
    navigationController?.popViewController(animated: true)
  }
  
  func exitTheApplication() {
    finishMyWalletsFlow(.exitTheApplication)
  }
  
  func openDeleteWalletSheet() {
    openRemoveWalletSheetModule()
  }
  
  func openRecoveryPhraseScreen(_ walletModel: SKAbstractions.WalletModel) {
    services.dataManagementService.modelHandlerService.getAppSettingsModel { [weak self] appSettingsModel in
      if appSettingsModel.appPassword == nil {
        self?.openListSeedPhraseScreenModule(walletModel, animated: true)
      } else {
        self?.openAuthenticationFlow { [weak self] in
          self?.openListSeedPhraseScreenModule(walletModel, animated: false)
        }
      }
    }
  }
  
  func openRenameWalletScreen(_ walletModel: WalletModel) {
    openMyWalletCustomizationScreenModule(walletModel)
  }
}

// MARK: - MyNewWalletSheetModuleOutput

extension MyWalletsFlowCoordinator: MyNewWalletSheetModuleOutput {
  func openCreateStandartSeedPhrase12WalletScreen() {
    dismissSheet { [weak self] in
      self?.openCreateWalletFlowCoordinator(.seedPhrase12)
    }
  }
  
  func openCreateIndestructibleSeedPhrase24WalletScreen() {
    dismissSheet { [weak self] in
      self?.openCreateWalletFlowCoordinator(.seedPhrase24)
    }
  }
  
  func openCreateHighTechImageIDWalletScreen() {
    dismissSheet { [weak self] in
      self?.openCreateWalletFlowCoordinator(.highTechImageID)
    }
  }
  
  func openImportSeedPhraseWalletScreen() {
    dismissSheet { [weak self] in
      self?.openRestoreWalletFlowCoordinator(.seedPhrase)
    }
  }
  
  func openImportImageHighTechWalletScreen() {
    dismissSheet { [weak self] in
      self?.openRestoreWalletFlowCoordinator(.highTechImageID)
    }
  }
  
  func openImportTrackWalletWalletScreen() {
    dismissSheet { [weak self] in
      self?.openRestoreWalletFlowCoordinator(.trackingWallet)
    }
  }
}

// MARK: - RemoveWalletSheetModuleOutput

extension MyWalletsFlowCoordinator: RemoveWalletSheetModuleOutput {
  func removeWalletSheetWasTapped() {
    removeWalletSheetModule?.viewController.dismiss(animated: true) { [weak self] in
      self?.myWalletSettingsScreenModule?.input.deleteWallet()
    }
  }
}

// MARK: - MyWalletCustomizationScreenModuleOutput

extension MyWalletsFlowCoordinator: MyWalletCustomizationScreenModuleOutput {
  func confirmCustomizationButtonPressed(_ walletModel: WalletModel) {
    myWalletSettingsScreenModule?.input.updateContent(walletModel)
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - SaveImageScreenModuleOutput

extension MyWalletsFlowCoordinator: SaveImageScreenModuleOutput {
  func saveImageIDButtonTapped(_ image: Data?) {
    services.accessAndSecurityManagementService.permissionService.requestGallery { [weak self] granted in
      switch granted {
      case true:
        self?.services.userInterfaceAndExperienceService.uiService.saveImageToGallery(image, completion: { isSuccess in
          switch isSuccess {
          case true:
            self?.services.userInterfaceAndExperienceService.notificationService.showNotification(
              .positive(
                title: OChatStrings.MyWalletsFlowCoordinatorLocalization.State.SaveHighTechImageID.success
              )
            )
          case false:
            self?.services.userInterfaceAndExperienceService.notificationService.showNotification(
              .negative(
                title: OChatStrings.MyWalletsFlowCoordinatorLocalization.State.SaveHighTechImageID.failure
              )
            )
          }
        })
      case false:
        self?.services.userInterfaceAndExperienceService.notificationService.showNotification(
          .negative(
            title: OChatStrings.MyWalletsFlowCoordinatorLocalization.State.PermissionGallery.failure
          ),
          action: { [weak self] in
            self?.services.userInterfaceAndExperienceService.systemService.openSettings()
          }
        )
      }
    }
  }
}

// MARK: - Open modules

private extension MyWalletsFlowCoordinator {
  func openMyWalletsScreenModule() {
    var myWalletsScreenModule = MyWalletsScreenAssembly().createModule(services)
    self.myWalletsScreenModule = myWalletsScreenModule
    myWalletsScreenModule.input.moduleOutput = self
    myWalletsScreenModule.viewController.hidesBottomBarWhenPushed = true
    
    navigationController?.pushViewController(
      myWalletsScreenModule.viewController,
      animated: true
    )
  }
  
  func openMyWalletSettingsScreenModule(_ walletModel: WalletModel) {
    var myWalletSettingsScreenModule = MyWalletSettingsScreenAssembly().createModule(
      services: services,
      walletModel: walletModel
    )
    self.myWalletSettingsScreenModule = myWalletSettingsScreenModule
    myWalletSettingsScreenModule.input.moduleOutput = self
    
    navigationController?.pushViewController(
      myWalletSettingsScreenModule.viewController,
      animated: true
    )
  }
  
  func openMyNewWalletSheetModule() {
    var myNewWalletSheetModule = MyNewWalletSheetAssembly().createModule()
    self.myNewWalletSheetModule = myNewWalletSheetModule
    myNewWalletSheetModule.input.moduleOutput = self
    
    navigationController?.presentBottomSheet(
      myNewWalletSheetModule.viewController,
      targetHeight: Constants.targetNewWalletHeight
    )
  }
  
  func openCreateWalletFlowCoordinator(_ walletType: CreateWalletFlowType) {
    let createWalletFlowCoordinator = CreateWalletFlowCoordinator(navigationController, services)
    self.createWalletFlowCoordinator = createWalletFlowCoordinator
    
    createWalletFlowCoordinator.finishFlow = { [weak self] _ in
      self?.createWalletFlowCoordinator?.viewController?.dismiss(animated: true)
      self?.createWalletFlowCoordinator = nil
    }
    createWalletFlowCoordinator.start(parameter: walletType)
  }
  
  func openRestoreWalletFlowCoordinator(_ walletType: RestoreWalletFlowType) {
    let restoreWalletFlowCoordinator = RestoreWalletFlowCoordinator(navigationController, services)
    self.restoreWalletFlowCoordinator = restoreWalletFlowCoordinator
    
    restoreWalletFlowCoordinator.finishFlow = { [weak self] _ in
      self?.restoreWalletFlowCoordinator?.viewController?.dismiss(animated: true)
      self?.restoreWalletFlowCoordinator = nil
    }
    restoreWalletFlowCoordinator.start(parameter: walletType)
  }
  
  func openRemoveWalletSheetModule() {
    var removeWalletSheetModule = RemoveWalletSheetAssembly().createModule()
    self.removeWalletSheetModule = removeWalletSheetModule
    removeWalletSheetModule.input.moduleOutput = self
    
    navigationController?.presentBottomSheet(
      removeWalletSheetModule.viewController,
      targetHeight: Constants.targetRemoveWalletHeight
    )
  }
  
  func openListSeedPhraseScreenModule(_ walletModel: WalletModel, animated: Bool) {
    let listSeedPhraseScreenModule = ListSeedPhraseScreenAssembly().createModule(
      services: services,
      screenType: .plainScreen,
      walletModel: walletModel
    )
    self.listSeedPhraseScreenModule = listSeedPhraseScreenModule
    
    navigationController?.pushViewController(
      listSeedPhraseScreenModule.viewController,
      animated: animated
    )
  }
  
  func openAuthenticationFlow(completion: (() -> Void)?) {
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
        myWalletsScreenModule?.viewController.navigationController?.popViewController(animated: false)
        completion?()
      case .failure:
        break
      }
      self.authenticationFlowCoordinator = nil
    }
    authenticationFlowCoordinator.start(parameter: .loginPasscode(.loginFaceID))
  }
  
  func openMyWalletCustomizationScreenModule(_ walletModel: WalletModel) {
    var myWalletCustomizationScreenModule = MyWalletCustomizationScreenAssembly().createModule(
      walletModel,
      services: services
    )
    self.myWalletCustomizationScreenModule = myWalletCustomizationScreenModule
    myWalletCustomizationScreenModule.input.moduleOutput = self
    
    navigationController?.pushViewController(
      myWalletCustomizationScreenModule.viewController,
      animated: true
    )
  }
  
  func openSaveImageScreenModule(_ walletModel: WalletModel, animated: Bool) {
    var saveImageScreenModule = SaveImageScreenAssembly().createModule(walletModel)
    self.saveImageScreenModule = saveImageScreenModule
    saveImageScreenModule.input.moduleOutput = self
    
    navigationController?.pushViewController(
      saveImageScreenModule.viewController,
      animated: animated
    )
  }
}

// MARK: - Private

private extension MyWalletsFlowCoordinator {
  func finishMyWalletsFlow(_ flowType: MyWalletsFinishFlowType) {
    myWalletsScreenModule = nil
    myWalletSettingsScreenModule = nil
    myNewWalletSheetModule = nil
    createWalletFlowCoordinator = nil
    restoreWalletFlowCoordinator = nil
    removeWalletSheetModule = nil
    listSeedPhraseScreenModule = nil
    authenticationFlowCoordinator = nil
    myWalletCustomizationScreenModule = nil
    saveImageScreenModule = nil
    finishFlow?(flowType)
  }
  
  func dismissSheet(completion: (() -> Void)?) {
    myNewWalletSheetModule?.viewController.dismiss(animated: true) {
      completion?()
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let targetNewWalletHeight: CGFloat = 510
  static let targetRemoveWalletHeight: CGFloat = 250
}
