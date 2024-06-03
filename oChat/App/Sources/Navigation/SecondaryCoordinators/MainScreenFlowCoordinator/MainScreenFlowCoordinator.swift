//
//  MainScreenFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

final class MainScreenFlowCoordinator: Coordinator<Void, MainScreenFinishFlowType> {
  
  // MARK: - Internal variables
  
  var navigationController: UINavigationController?
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  private var mainScreenModule: MainScreenModule?
  
  private var sendPaymentFlowCoordinator: SendPaymentFlowCoordinator?
  private var receivePaymentFlowCoordinator: ReceivePaymentFlowCoordinator?
  private var listTokensScreenModule: ListTokensScreenModule?
  private var detailPaymentFlowCoordinator: DetailPaymentFlowCoordinator?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы приложения
  init(_ services: IApplicationServices) {
    self.services = services
  }
  
  // MARK: - Internal func
  
  override func start(parameter: Void) {
    var mainScreenModule = MainScreenAssembly().createModule()
    self.mainScreenModule = mainScreenModule
    mainScreenModule.input.moduleOutput = self
    navigationController = mainScreenModule.viewController.wrapToNavigationController()
  }
}

// MARK: - MainScreenModuleOutput

extension MainScreenFlowCoordinator: MainScreenModuleOutput {
  func openDetailCoinScreen(_ tokenModel: SKAbstractions.TokenModel) {
    openDetailPaymentFlow(tokenModel)
  }
  
  func openAddTokenScreen(tokenModels: [SKAbstractions.TokenModel]) {
    openListTokensScreenModule(tokenModels)
  }
  
  func openSendCoinScreen() {
    openSendPaymentFlow(.openFromMainScreen)
  }
  
  func openReceiveCoinScreen() {
    openReceivePaymentFlowCoordinatorFlow()
  }
}

// MARK: - ListTokensScreenModuleOutput

extension MainScreenFlowCoordinator: ListTokensScreenModuleOutput {
  func tokenSelected(_ model: SKAbstractions.TokenModel) {}
  
  func tokensIsActived(_ models: [SKAbstractions.TokenModel]) {
    mainScreenModule?.input.updateTokens(models)
  }
}

// MARK: - Open modules

private extension MainScreenFlowCoordinator {
  func openSendPaymentFlow(_ flowType: SendPaymentFlowType) {
    let sendPaymentFlowCoordinator = SendPaymentFlowCoordinator(navigationController, services)
    self.sendPaymentFlowCoordinator = sendPaymentFlowCoordinator
    
    sendPaymentFlowCoordinator.finishFlow = { [weak self] state in
      switch state {
      case .success:
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
          self?.services.userInterfaceAndExperienceService.notificationService.showNotification(
            .positive(
              title: oChatStrings.MainScreenFlowCoordinatorLocalization
                .State.SendPaymentFlow.success
            )
          )
        }
      case .failure, .close:
        break
      }
      self?.sendPaymentFlowCoordinator = nil
    }
    
    sendPaymentFlowCoordinator.start(parameter: flowType)
  }
  
  func openReceivePaymentFlowCoordinatorFlow() {
    let receivePaymentFlowCoordinator = ReceivePaymentFlowCoordinator(navigationController, services)
    self.receivePaymentFlowCoordinator = receivePaymentFlowCoordinator
    
    receivePaymentFlowCoordinator.finishFlow = { [weak self] _ in
      self?.receivePaymentFlowCoordinator = nil
    }
    
    receivePaymentFlowCoordinator.start(parameter: .initial)
  }
  
  func openListTokensScreenModule(_ tokenModels: [TokenModel]) {
    var listTokensScreenModule = ListTokensScreenAssembly().createModule(
      screenType: .addTokenOnMainScreen(tokenModels: tokenModels)
    )
    self.listTokensScreenModule = listTokensScreenModule
    listTokensScreenModule.input.moduleOutput = self
    listTokensScreenModule.viewController.hidesBottomBarWhenPushed = true
    
    navigationController?.pushViewController(
      listTokensScreenModule.viewController,
      animated: true
    )
  }
  
  func openDetailPaymentFlow(_ tokenModel: TokenModel) {
    let detailPaymentFlowCoordinator = DetailPaymentFlowCoordinator(
      navigationController,
      services: services,
      model: tokenModel
    )
    self.detailPaymentFlowCoordinator = detailPaymentFlowCoordinator
    
    detailPaymentFlowCoordinator.finishFlow = { [weak self] _ in
      self?.detailPaymentFlowCoordinator = nil
    }
    
    detailPaymentFlowCoordinator.start()
  }
}

// MARK: - Private

private extension MainScreenFlowCoordinator {
  func finishMainScreenFlow(_ flowType: MainScreenFinishFlowType) {
    mainScreenModule = nil
    sendPaymentFlowCoordinator = nil
    receivePaymentFlowCoordinator = nil
    listTokensScreenModule = nil
    detailPaymentFlowCoordinator = nil
    finishFlow?(flowType)
  }
}
