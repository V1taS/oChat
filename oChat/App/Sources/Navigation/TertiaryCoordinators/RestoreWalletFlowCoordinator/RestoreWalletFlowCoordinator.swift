//
//  RestoreWalletFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

final class RestoreWalletFlowCoordinator: Coordinator<RestoreWalletFlowType, RestoreWalletFinishFlowType> {
  
  // MARK: - Internal variables
  
  let viewController: UIViewController?
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  
  private var importWalletScreenModule: ImportWalletScreenModule?
  private var createHighTechLoginImageIDScreenModule: HighTechImageIDScreenModule?
  private var suggestAccessCodeScreenModule: SuggestScreenModule?
  private var highTechImageIDInfoSheetModule: HighTechImageIDInfoSheetModule?
  private var suggestNotificationsScreenModule: SuggestScreenModule?
  private var authenticationFlowCoordinator: AuthenticationFlowCoordinator?
  private var suggestFaceIDScreenModule: SuggestScreenModule?
  
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
  
  override func start(parameter: RestoreWalletFlowType) {
    switch parameter {
    case .seedPhrase:
      openPhraseWalletScreenModule(.seedPhrase)
    case .highTechImageID:
      openHighTechLoginImageIDScreenModule()
    case .trackingWallet:
      openPhraseWalletScreenModule(.trackingWallet)
    }
  }
}

// MARK: - ImportWalletScreenModuleOutput

extension RestoreWalletFlowCoordinator: ImportWalletScreenModuleOutput {
  func closeImportWalletScreenButtonTapped() {
    finishRestoreWalletFlow(.failure)
  }
  
  func successImportWalletScreen() {
    openSuggestAccessCodeScreenModule()
  }
}

// MARK: - HighTechImageIDScreenModuleOutput

extension RestoreWalletFlowCoordinator: HighTechImageIDScreenModuleOutput {
  func saveHighTechImageIDToGallery(_ image: Data?) {}
  func successCreatedHighTechImageIDScreen() {}
  
  func closeButtonHighTechImageIDScreenTapped() {
    finishRestoreWalletFlow(.failure)
  }
  
  func openInfoImageIDSheet() {
    openHighTechImageIDInfoSheetModule()
  }
  
  func successLoginHighTechImageIDScreen() {
    openSuggestAccessCodeScreenModule()
  }
}

// MARK: - SuggestScreenModuleOutput

extension RestoreWalletFlowCoordinator: SuggestScreenModuleOutput {
  func skipSuggestAccessCodeScreenButtonTapped(_ isNotifications: Bool) {
    switch isNotifications {
    case true:
      finishRestoreWalletFlow(.success)
    case false:
      openSuggestNotificationsScreenModule()
    }
  }
  
  func skipSuggestNotificationsScreenButtonTapped() {
    finishRestoreWalletFlow(.success)
  }
  
  func suggestAccessCodeScreenConfirmButtonTapped() {
    openAuthenticationFlow(.createPasscode(.enterPasscode))
  }
  
  func suggestFaceIDScreenConfirmButtonTapped(_ isEnabledNotifications: Bool) {
    switch isEnabledNotifications {
    case true:
      finishRestoreWalletFlow(.success)
    case false:
      openSuggestNotificationsScreenModule()
    }
  }
  
  func suggestNotificationScreenConfirmButtonTapped() {
    finishRestoreWalletFlow(.success)
  }
}

// MARK: - HighTechImageIDInfoSheetModuleOutput

extension RestoreWalletFlowCoordinator: HighTechImageIDInfoSheetModuleOutput {}

// MARK: - Open modules

private extension RestoreWalletFlowCoordinator {
  func openPhraseWalletScreenModule(_ walletType: ImportWalletScreenType) {
    var importWalletScreenModule = ImportWalletScreenAssembly().createModule(walletType: walletType, services: services)
    self.importWalletScreenModule = importWalletScreenModule
    importWalletScreenModule.input.moduleOutput = self
    
    viewController?.presentFullScreen(importWalletScreenModule.viewController.wrapToNavigationController())
  }
  
  func openHighTechLoginImageIDScreenModule() {
    var createHighTechLoginImageIDScreenModule = HighTechImageIDScreenAssembly().createModule(
      state: .loginImageID(.initialState),
      services: services, 
      walletModel: nil
    )
    self.createHighTechLoginImageIDScreenModule = createHighTechLoginImageIDScreenModule
    createHighTechLoginImageIDScreenModule.input.moduleOutput = self
    viewController?.presentFullScreen(createHighTechLoginImageIDScreenModule.viewController.wrapToNavigationController())
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
  
  func openHighTechImageIDInfoSheetModule() {
    var highTechImageIDInfoSheetModule = HighTechImageIDInfoSheetAssembly().createModule()
    self.highTechImageIDInfoSheetModule = highTechImageIDInfoSheetModule
    highTechImageIDInfoSheetModule.input.moduleOutput = self
    
    UIViewController.topController?.presentBottomSheet(
      highTechImageIDInfoSheetModule.viewController,
      targetHeight: Constants.targetHeight
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
    }
    
    authenticationFlowCoordinator.start(parameter: state)
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
}

// MARK: - Private

private extension RestoreWalletFlowCoordinator {
  func finishRestoreWalletFlow(_ flowType: RestoreWalletFinishFlowType) {
    importWalletScreenModule = nil
    createHighTechLoginImageIDScreenModule = nil
    suggestAccessCodeScreenModule = nil
    highTechImageIDInfoSheetModule = nil
    suggestNotificationsScreenModule = nil
    authenticationFlowCoordinator = nil
    suggestFaceIDScreenModule = nil
    finishFlow?(flowType)
  }
}

// MARK: - Constants

private enum Constants {
  static let targetHeight: CGFloat = 350
}
