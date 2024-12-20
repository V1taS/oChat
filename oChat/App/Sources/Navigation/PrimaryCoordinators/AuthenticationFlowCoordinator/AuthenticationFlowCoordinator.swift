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
  private let flowType: AuthenticationScreenFlowType
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы приложения
  ///   - viewController: Вью контроллер
  ///   - openType: Способ открытия
  ///   - flowType: Тип флоу
  public init(_ services: IApplicationServices,
              viewController: UIViewController? = nil,
              openType: AuthenticationFlowOpenType = .present,
              flowType: AuthenticationScreenFlowType) {
    self.services = services
    self.viewController = viewController
    self.openType = openType
    self.flowType = flowType
  }
  
  // MARK: - Internal func
  
  public override func start(parameter: AuthenticationScreenState) {
    var authenticationScreenModule = AuthenticationScreenAssembly().createModule(
      services,
      parameter,
      flowType: flowType
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
  public func allDataErased() {
    finishAuthenticationFlow(.allDataErased)
  }
  
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
