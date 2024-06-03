//
//  DetailPaymentFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

final class DetailPaymentFlowCoordinator: Coordinator<Void, DetailPaymentFinishFlowType> {
  
  // MARK: - Internal variables
  
  let navigationController: UINavigationController?
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  private let model: TokenModel
  
  private var detailPaymentScreenModule: DetailPaymentScreenModule?
  private var sendPaymentFlowCoordinator: SendPaymentFlowCoordinator?
  private var receivePaymentFlowCoordinator: ReceivePaymentFlowCoordinator?
  private var transactionInformationSheetModule: TransactionInformationSheetModule?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - navigationController: Основной Навигейшен вью контроллер
  ///   - services: Сервисы приложения
  ///   - model: Модель токена
  init(_ navigationController: UINavigationController?,
       services: IApplicationServices,
       model: TokenModel) {
    self.navigationController = navigationController
    self.services = services
    self.model = model
  }
  
  // MARK: - Internal func
  
  override func start(parameter: Void) {
    openDetailPaymentScreenModule(model)
  }
}

// MARK: - DetailPaymentScreenModuleOutput

extension DetailPaymentFlowCoordinator: DetailPaymentScreenModuleOutput {
  func openTransactionInformationSheet(_ tokenModel: SKAbstractions.TokenModel) {
    openTransactionInformationSheetModule()
  }
  
  func openSendPaymentScreen(_ tokenModel: SKAbstractions.TokenModel) {
    openSendPaymentFlowCoordinator(tokenModel)
  }
  
  func openReceivePaymentScreen(_ tokenModel: SKAbstractions.TokenModel) {
    openReceivePaymentFlowCoordinator(tokenModel)
  }
}

// MARK: - TransactionInformationSheetModuleOutput

extension DetailPaymentFlowCoordinator: TransactionInformationSheetModuleOutput {}

// MARK: - Open modules

private extension DetailPaymentFlowCoordinator {
  func openDetailPaymentScreenModule(_ model: TokenModel) {
    var detailPaymentScreenModule = DetailPaymentScreenAssembly().createModule(tokenModel: model)
    self.detailPaymentScreenModule = detailPaymentScreenModule
    detailPaymentScreenModule.input.moduleOutput = self
    
    detailPaymentScreenModule.viewController.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(
      detailPaymentScreenModule.viewController,
      animated: true
    )
  }
  
  func openSendPaymentFlowCoordinator(_ model: TokenModel) {
    let sendPaymentFlowCoordinator = SendPaymentFlowCoordinator(navigationController, services)
    self.sendPaymentFlowCoordinator = sendPaymentFlowCoordinator
    
    sendPaymentFlowCoordinator.finishFlow = { [weak self] state in
      Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
        guard let self else {
          return
        }
        
        if case .success = state {
          services.userInterfaceAndExperienceService.notificationService.showNotification(
            .positive(
              title: oChatStrings.DetailPaymentFlowCoordinatorLocalization
                .State.SendPaymentFlow.success
            )
          )
        }
      }
      self?.sendPaymentFlowCoordinator = nil
    }
    
    sendPaymentFlowCoordinator.start(parameter: .openFromDetailScreen(model))
  }
  
  func openReceivePaymentFlowCoordinator(_ model: TokenModel) {
    let receivePaymentFlowCoordinator = ReceivePaymentFlowCoordinator(navigationController, services)
    self.receivePaymentFlowCoordinator = receivePaymentFlowCoordinator
    
    receivePaymentFlowCoordinator.finishFlow = { [weak self] _ in
      self?.receivePaymentFlowCoordinator = nil
    }
    
    receivePaymentFlowCoordinator.start(parameter: .shareRequisites(model))
  }
  
  func openTransactionInformationSheetModule() {
    var transactionInformationSheetModule = TransactionInformationSheetAssembly().createModule(
      model: .singleMock,
      services: services
    )
    self.transactionInformationSheetModule = transactionInformationSheetModule
    transactionInformationSheetModule.input.moduleOutput = self
    
    navigationController?.presentBottomSheet(
      transactionInformationSheetModule.viewController,
      targetHeight: Constants.targetHeight
    )
  }
}

// MARK: - Private

private extension DetailPaymentFlowCoordinator {
  func finishDetailPaymentFlow(_ flowType: DetailPaymentFinishFlowType) {
    detailPaymentScreenModule = nil
    sendPaymentFlowCoordinator = nil
    receivePaymentFlowCoordinator = nil
    transactionInformationSheetModule = nil
    finishFlow?(flowType)
  }
}

// MARK: - Constants

private enum Constants {
  static let targetHeight: CGFloat = 420
}
