//
//  InitialFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

final class InitialFlowCoordinator: Coordinator<Void, InitialFinishFlowType> {
  
  // MARK: - Internal variables
  
  var viewController: UIViewController?
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  private let isPresentScreenAnimated: Bool
  
  private var initialScreenModule: InitialScreenModule?
  private var createOrRestoreWalletSheetModule: CreateOrRestoreWalletSheetModule?
  private var createWalletFlowCoordinator: CreateWalletFlowCoordinator?
  private var restoreWalletFlowCoordinator: RestoreWalletFlowCoordinator?
  
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
    var initialScreenModule = InitialScreenAssembly().createModule(services)
    self.initialScreenModule = initialScreenModule
    initialScreenModule.input.moduleOutput = self
    viewController = initialScreenModule.viewController
    initialScreenModule.viewController.presentAsRoot(animated: isPresentScreenAnimated)
  }
}

// MARK: - InitialScreenModuleOutput

extension InitialFlowCoordinator: InitialScreenModuleOutput {
  func newWalletButtonTapped() {
    openCreateOrRestoreWalletSheet(.createWallet)
  }
  
  func importWalletButtonTapped() {
    openCreateOrRestoreWalletSheet(.restoreWallet)
  }
}

// MARK: - CreateOrRestoreWalletSheetModuleOutput

extension InitialFlowCoordinator: CreateOrRestoreWalletSheetModuleOutput {
  func createStandartSeedPhrase12WalletButtonTapped() {
    dismissSheet { [weak self] in
      self?.openCreateWalletFlowCoordinator(.seedPhrase12)
    }
  }
  
  func createIndestructibleSeedPhrase24WalletButtonTapped() {
    dismissSheet { [weak self] in
      self?.openCreateWalletFlowCoordinator(.seedPhrase24)
    }
  }
  
  func createHighTechImageIDWalletButtonTapped() {
    dismissSheet { [weak self] in
      self?.openCreateWalletFlowCoordinator(.highTechImageID)
    }
  }
  
  func restoreWalletButtonTapped() {
    dismissSheet { [weak self] in
      self?.openRestoreWalletFlowCoordinator(.seedPhrase)
    }
  }
  
  func restoreHighTechImageIDWalletButtonTapped() {
    dismissSheet { [weak self] in
      self?.openRestoreWalletFlowCoordinator(.highTechImageID)
    }
  }
  
  func restoreWalletForObserverButtonTapped() {
    dismissSheet { [weak self] in
      self?.openRestoreWalletFlowCoordinator(.trackingWallet)
    }
  }
}

// MARK: - Open modules

private extension InitialFlowCoordinator {
  func openCreateOrRestoreWalletSheet(_ sheetType: CreateOrRestoreWalletSheetType) {
    var createOrRestoreWalletSheetModule = CreateOrRestoreWalletSheetAssembly().createModule(sheetType: sheetType)
    self.createOrRestoreWalletSheetModule = createOrRestoreWalletSheetModule
    createOrRestoreWalletSheetModule.input.moduleOutput = self
    viewController?.presentBottomSheet(
      createOrRestoreWalletSheetModule.viewController,
      targetHeight: sheetType == .createWallet ? Constants.targetCreateWalletHeight : Constants.targetRestoreWalletHeight
    )
  }
  
  func openCreateWalletFlowCoordinator(_ walletType: CreateWalletFlowType) {
    let createWalletFlowCoordinator = CreateWalletFlowCoordinator(
      viewController,
      services
    )
    self.createWalletFlowCoordinator = createWalletFlowCoordinator
    
    createWalletFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .success:
        self?.finishInitialFlow(.success)
      case .failure:
        self?.createWalletFlowCoordinator?.viewController?.dismiss(animated: true)
        self?.createWalletFlowCoordinator = nil
      }
    }
    createWalletFlowCoordinator.start(parameter: walletType)
  }
  
  func openRestoreWalletFlowCoordinator(_ walletType: RestoreWalletFlowType) {
    let restoreWalletFlowCoordinator = RestoreWalletFlowCoordinator(viewController, services)
    self.restoreWalletFlowCoordinator = restoreWalletFlowCoordinator
    
    restoreWalletFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .success:
        self?.finishInitialFlow(.success)
      case .failure:
        self?.restoreWalletFlowCoordinator?.viewController?.dismiss(animated: true)
        self?.restoreWalletFlowCoordinator = nil
      }
    }
    restoreWalletFlowCoordinator.start(parameter: walletType)
  }
}

// MARK: - Private

private extension InitialFlowCoordinator {
  func finishInitialFlow(_ type: InitialFinishFlowType) {
    initialScreenModule = nil
    createOrRestoreWalletSheetModule = nil
    createWalletFlowCoordinator = nil
    restoreWalletFlowCoordinator = nil
    finishFlow?(type)
  }
  
  func dismissSheet(completion: (() -> Void)?) {
    createOrRestoreWalletSheetModule?.viewController.dismiss(animated: true) {
      completion?()
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let targetCreateWalletHeight: CGFloat = 280
  static let targetRestoreWalletHeight: CGFloat = 200
}
