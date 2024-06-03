//
//  SendPaymentFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

final class SendPaymentFlowCoordinator: Coordinator<SendPaymentFlowType, SendPaymentFinishFlowType> {
  
  // MARK: - Internal variables
  
  let navigationController: UINavigationController?
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  
  private var sendPaymentScreenModel: SendPaymentScreenModule?
  private var listTokensScreenModule: ListTokensScreenModule?
  private var listNetworksScreenModule: ListNetworksScreenModule?
  private var confirmSendPaymentScreenModule: ConfirmSendPaymentScreenModule?
  
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
  
  override func start(parameter: SendPaymentFlowType) {
    switch parameter {
    case .openFromMainScreen:
      openSendPaymentScreenModel(.init(screenType: .openFromMainScreen, tokenModel: .solanaMock))
    case let .openFromDetailScreen(model):
      openSendPaymentScreenModel(.init(screenType: .openFromDetailScreen, tokenModel: model))
    }
  }
}

// MARK: - SendPaymentScreenModuleOutput

extension SendPaymentFlowCoordinator: SendPaymentScreenModuleOutput {
  func openConfirmAndSendScreen(_ model: SKAbstractions.TokenModel, recipientAddress: String) {
    openConfirmSendPaymentScreenModule(model, recipientAddress: recipientAddress)
  }
  
  func openNetworkTokensScreen(_ model: TokenModel) {
    openListNetworksScreenModule(model)
  }
  
  func closeSendPaymentScreenButtonTapped() {
    finishSendPaymentFlow(.close)
  }
  
  func openListTokensScreen(_ model: TokenModel) {
    openListTokensScreenModule(model)
  }
}

// MARK: - ListTokensScreenModuleOutput

extension SendPaymentFlowCoordinator: ListTokensScreenModuleOutput {
  func tokenSelected(_ model: SKAbstractions.TokenModel) {
    listTokensScreenModule?.viewController.dismiss(animated: true)
    listTokensScreenModule = nil
    sendPaymentScreenModel?.input.tokenSelected(model)
  }
}

// MARK: - ListNetworksScreenModuleOutput

extension SendPaymentFlowCoordinator: ListNetworksScreenModuleOutput {
  func networkSelected(_ model: SKAbstractions.TokenNetworkType) {
    listNetworksScreenModule?.viewController.dismiss(animated: true)
    listNetworksScreenModule = nil
    sendPaymentScreenModel?.input.networkSelected(model)
  }
}

// MARK: - ConfirmSendPaymentScreenModuleOutput

extension SendPaymentFlowCoordinator: ConfirmSendPaymentScreenModuleOutput {
  func paymentSentSuccessfully() {
    finishSendPaymentFlow(.success)
  }
  
  func paymentNotSent() {
    finishSendPaymentFlow(.failure)
  }
}

// MARK: - Open modules

private extension SendPaymentFlowCoordinator {
  func openSendPaymentScreenModel(_ paymentType: SendPaymentScreenModel) {
    var sendPaymentScreenModel = SendPaymentScreenAssembly().createModule(paymentType, services)
    self.sendPaymentScreenModel = sendPaymentScreenModel
    sendPaymentScreenModel.input.moduleOutput = self
    
    navigationController?.present(sendPaymentScreenModel.viewController.wrapToNavigationController(), animated: true)
  }
  
  func openListTokensScreenModule(_ tokenModel: TokenModel) {
    var listTokensScreenModule = ListTokensScreenAssembly().createModule(
      screenType: .tokenSelectioList(tokenModel: tokenModel)
    )
    self.listTokensScreenModule = listTokensScreenModule
    listTokensScreenModule.input.moduleOutput = self
    
    UIViewController.topController?.present(
      listTokensScreenModule.viewController.wrapToNavigationController(),
      animated: true
    )
  }
  
  func openListNetworksScreenModule(_ model: TokenModel) {
    var listNetworksScreenModule = ListNetworksScreenAssembly().createModule(model)
    self.listNetworksScreenModule = listNetworksScreenModule
    listNetworksScreenModule.input.moduleOutput = self
    
    UIViewController.topController?.present(
      listNetworksScreenModule.viewController.wrapToNavigationController(),
      animated: true
    )
  }
  
  func openConfirmSendPaymentScreenModule(_ model: TokenModel, recipientAddress: String) {
    var confirmSendPaymentScreenModule = ConfirmSendPaymentScreenAssembly().createModule(
      model,
      recipientAddress: recipientAddress,
      services: services
    )
    self.confirmSendPaymentScreenModule = confirmSendPaymentScreenModule
    confirmSendPaymentScreenModule.input.moduleOutput = self
    
    DispatchQueue.main.async { [weak self] in
      self?.sendPaymentScreenModel?.viewController.navigationController?.pushViewController(
        confirmSendPaymentScreenModule.viewController,
        animated: true
      )
    }
  }
}

// MARK: - Private

private extension SendPaymentFlowCoordinator {
  func finishSendPaymentFlow(_ flowType: SendPaymentFinishFlowType) {
    sendPaymentScreenModel = nil
    listTokensScreenModule = nil
    listNetworksScreenModule = nil
    confirmSendPaymentScreenModule = nil
    navigationController?.dismiss(animated: true)
    finishFlow?(flowType)
  }
}

// MARK: - Constants

private enum Constants {}
