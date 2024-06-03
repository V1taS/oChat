//
//  ActivityScreenFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

final class ActivityScreenFlowCoordinator: Coordinator<Void, ActivityScreenFinishFlowType> {
  
  // MARK: - Internal variables
  
  var navigationController: UINavigationController?
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  private var activityScreenModule: ActivityScreenModule?
  private var transactionInformationSheetModule: TransactionInformationSheetModule?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы приложения
  init(_ services: IApplicationServices) {
    self.services = services
  }
  
  // MARK: - Internal func
  
  override func start(parameter: Void) {
    var activityScreenModule = ActivityScreenAssembly().createModule()
    self.activityScreenModule = activityScreenModule
    activityScreenModule.input.moduleOutput = self
    navigationController = activityScreenModule.viewController.wrapToNavigationController()
  }
}

// MARK: - ActivityScreenModuleOutput

extension ActivityScreenFlowCoordinator: ActivityScreenModuleOutput {
  func openActivitySheet() {
    openTransactionInformationSheetModule()
  }
}

// MARK: - TransactionInformationSheetModuleOutput

extension ActivityScreenFlowCoordinator: TransactionInformationSheetModuleOutput {}

// MARK: - Open modules

private extension ActivityScreenFlowCoordinator {
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

private extension ActivityScreenFlowCoordinator {
  func finishActivityScreenFlow(_ flowType: ActivityScreenFinishFlowType) {
    activityScreenModule = nil
    transactionInformationSheetModule = nil
    finishFlow?(flowType)
  }
}

// MARK: - Constants

private enum Constants {
  static let targetHeight: CGFloat = 420
}
