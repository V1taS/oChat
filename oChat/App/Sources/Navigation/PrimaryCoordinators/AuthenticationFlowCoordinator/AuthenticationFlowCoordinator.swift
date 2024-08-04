//
//  AuthenticationFlowCoordinator.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

public final class AuthenticationFlowCoordinator: Coordinator<AuthenticationScreenState, AuthenticationFinishFlowType> {
  
  // MARK: - Internal variables
  
  public var viewController: UIViewController?
  public let openType: AuthenticationFlowOpenType
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  private var authenticationScreenModule: AuthenticationScreenModule?
  private let isFake: Bool
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы приложения
  ///   - viewController: Вью контроллер
  ///   - openType: Способ открытия
  ///   - isFake: Флоу фейковых данных
  public init(_ services: IApplicationServices,
              viewController: UIViewController? = nil,
              openType: AuthenticationFlowOpenType = .present,
              isFake: Bool) {
    self.services = services
    self.viewController = viewController
    self.openType = openType
    self.isFake = isFake
  }
  
  // MARK: - Internal func
  
  public override func start(parameter: AuthenticationScreenState) {
    var authenticationScreenModule = AuthenticationScreenAssembly().createModule(
      services,
      parameter,
      isFake: isFake
    )
    self.authenticationScreenModule = authenticationScreenModule
    authenticationScreenModule.input.moduleOutput = self
    authenticationScreenModule.viewController.hidesBottomBarWhenPushed = true
    
    if let viewController {
      switch openType {
      case .push:
        if let navigationController = viewController as? UINavigationController {
          navigationController.pushViewController(
            authenticationScreenModule.viewController,
            animated: true
          )
        } else {
          let navigationController = viewController.wrapToNavigationController()
          navigationController.pushViewController(
            authenticationScreenModule.viewController,
            animated: true
          )
        }
      case .present:
        viewController.presentFullScreen(
          authenticationScreenModule.viewController,
          animated: false
        )
      }
      
      return
    }
    authenticationScreenModule.viewController.presentAsRoot()
  }
}

// MARK: - AuthenticationScreenModuleOutput

extension AuthenticationFlowCoordinator: AuthenticationScreenModuleOutput {
  public func authenticationFakeSuccess() {
    finishAuthenticationFlow(.successFake)
  }
  
  public func authenticationSuccess() {
    finishAuthenticationFlow(.success)
  }
}

// MARK: - Private

private extension AuthenticationFlowCoordinator {
  func finishAuthenticationFlow(_ state: AuthenticationFinishFlowType) {
    authenticationScreenModule = nil
    finishFlow?(state)
  }
}
