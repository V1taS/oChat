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
  func continueButtonTapped() {
    finishInitialFlow(.success)
  }
}

// MARK: - Open modules

private extension InitialFlowCoordinator {}

// MARK: - Private

private extension InitialFlowCoordinator {
  func finishInitialFlow(_ type: InitialFinishFlowType) {
    initialScreenModule = nil
    finishFlow?(type)
  }
}

// MARK: - Constants

private enum Constants {}
