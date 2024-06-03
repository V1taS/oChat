//
//  ReceivePaymentFlowCoordinator.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKAbstractions
import UIKit

final class ReceivePaymentFlowCoordinator: Coordinator<ReceivePaymentFlowType, ReceivePaymentFinishFlowType> {
  
  // MARK: - Internal variables
  
  let navigationController: UINavigationController?
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  
  private var receivePaymentScreenModule: ReceivePaymentScreenModule?
  private var listTokensScreenModule: ListTokensScreenModule?
  private var listNetworksScreenModule: ListNetworksScreenModule?
  private var qrReceivePaymentScreenModule: QRReceivePaymentScreenModule?
  
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
  
  override func start(parameter: ReceivePaymentFlowType) {
    switch parameter {
    case .initial:
      openReceivePaymentScreenModule()
    case let .shareRequisites(model):
      openQRReceivePaymentScreenModule(model, flowType: parameter)
    }
  }
}

// MARK: - ReceivePaymentScreenModuleOutput

extension ReceivePaymentFlowCoordinator: ReceivePaymentScreenModuleOutput {
  func openNetworkSelectionScreen(_ tokenModel: SKAbstractions.TokenModel) {
    openListNetworksScreenModule(tokenModel)
  }
  
  func openListTokensScreen(_ tokenModel: SKAbstractions.TokenModel) {
    openListTokensScreenModule(tokenModel)
  }
  
  func continueButtonReceivePaymentPressed(_ model: SKAbstractions.TokenModel) {
    openQRReceivePaymentScreenModule(model, flowType: .initial)
  }
  
  func closeReceivePaymentScreenButtonTapped() {
    finishReceivePaymentFlow(.close)
  }
}

// MARK: - ListTokensScreenModuleOutput

extension ReceivePaymentFlowCoordinator: ListTokensScreenModuleOutput {
  func tokenSelected(_ model: SKAbstractions.TokenModel) {
    listTokensScreenModule?.viewController.dismiss(animated: true)
    listTokensScreenModule = nil
    receivePaymentScreenModule?.input.updateTokenModel(model)
  }
}

// MARK: - ListNetworksScreenModuleOutput

extension ReceivePaymentFlowCoordinator: ListNetworksScreenModuleOutput {
  func networkSelected(_ model: SKAbstractions.TokenNetworkType) {
    listNetworksScreenModule?.viewController.dismiss(animated: true)
    listNetworksScreenModule = nil
    receivePaymentScreenModule?.input.updateNetwork(model)
  }
}

// MARK: - QRReceivePaymentScreenModuleOutput

extension ReceivePaymentFlowCoordinator: QRReceivePaymentScreenModuleOutput {
  func shareQRReceivePaymentScreenTapped(_ image: UIImage?, name: String) {
    shareButtonAction(image: image, name: name)
  }
  
  func closeQRReceivePaymentScreenTapped() {
    finishReceivePaymentFlow(.close)
  }
}

// MARK: - Open modules

private extension ReceivePaymentFlowCoordinator {
  func openReceivePaymentScreenModule() {
    var receivePaymentScreenModule = ReceivePaymentScreenAssembly().createModule()
    self.receivePaymentScreenModule = receivePaymentScreenModule
    receivePaymentScreenModule.input.moduleOutput = self
    
    navigationController?.present(receivePaymentScreenModule.viewController.wrapToNavigationController(), animated: true)
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
  
  func openQRReceivePaymentScreenModule(_ model: TokenModel, flowType: ReceivePaymentFlowType) {
    var qrReceivePaymentScreenModule = QRReceivePaymentScreenAssembly().createModule(services: services, tokenModel: model)
    self.qrReceivePaymentScreenModule = qrReceivePaymentScreenModule
    qrReceivePaymentScreenModule.input.moduleOutput = self
    
    switch flowType {
    case .initial:
      DispatchQueue.main.async { [weak self] in
        self?.receivePaymentScreenModule?.viewController.navigationController?.pushViewController(
          qrReceivePaymentScreenModule.viewController,
          animated: true
        )
      }
    case .shareRequisites:
      navigationController?.present(qrReceivePaymentScreenModule.viewController.wrapToNavigationController(), animated: true)
    }
  }
}

// MARK: - Private

private extension ReceivePaymentFlowCoordinator {
  func finishReceivePaymentFlow(_ flowType: ReceivePaymentFinishFlowType) {
    receivePaymentScreenModule = nil
    listTokensScreenModule = nil
    listNetworksScreenModule = nil
    qrReceivePaymentScreenModule = nil
    navigationController?.dismiss(animated: true)
    finishFlow?(flowType)
  }
  
  func shareButtonAction(image: UIImage?, name: String) {
    guard let image,
          let imageData = image.jpegData(compressionQuality: 0.1),
          let imageFile = services.dataManagementService.dataManagerService.saveObjectWith(
            fileName: name,
            fileExtension: ".jpg",
            data: imageData
          ) else {
      return
    }
    
    let activityViewController = UIActivityViewController(activityItems: [imageFile],
                                                          applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = qrReceivePaymentScreenModule?.viewController.view
    activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop,
                                                    UIActivity.ActivityType.postToFacebook,
                                                    UIActivity.ActivityType.message,
                                                    UIActivity.ActivityType.addToReadingList,
                                                    UIActivity.ActivityType.assignToContact,
                                                    UIActivity.ActivityType.copyToPasteboard,
                                                    UIActivity.ActivityType.markupAsPDF,
                                                    UIActivity.ActivityType.openInIBooks,
                                                    UIActivity.ActivityType.postToFlickr,
                                                    UIActivity.ActivityType.postToTencentWeibo,
                                                    UIActivity.ActivityType.postToTwitter,
                                                    UIActivity.ActivityType.postToVimeo,
                                                    UIActivity.ActivityType.postToWeibo,
                                                    UIActivity.ActivityType.print]
    
    if UIDevice.current.userInterfaceIdiom == .pad {
      if let popup = activityViewController.popoverPresentationController {
        popup.sourceView = qrReceivePaymentScreenModule?.viewController.view
        popup.sourceRect = CGRect(x: (qrReceivePaymentScreenModule?.viewController.view.frame.size.width ?? .zero) / 2,
                                  y: (qrReceivePaymentScreenModule?.viewController.view.frame.size.height ?? .zero) / 4,
                                  width: .zero,
                                  height: .zero)
      }
    }
    
    qrReceivePaymentScreenModule?.viewController.present(
      activityViewController,
      animated: true,
      completion: {
        [weak self] in
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
          self?.services.dataManagementService.dataManagerService.deleteObjectWith(
            fileURL: imageFile,
            isRemoved: {
              _ in
            }
          )
        }
      }
    )
  }
}

// MARK: - Constants

private enum Constants {}
