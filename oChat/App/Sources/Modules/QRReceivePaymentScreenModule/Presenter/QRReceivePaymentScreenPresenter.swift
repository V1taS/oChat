//
//  QRReceivePaymentScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class QRReceivePaymentScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateReplenishmentAddress = ""
  @Published var stateQrImage: Image?
  @Published var stateTokenModel: TokenModel
  
  // MARK: - Internal properties
  
  weak var moduleOutput: QRReceivePaymentScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: QRReceivePaymentScreenInteractorInput
  private let factory: QRReceivePaymentScreenFactoryInput
  private var cacheQrImage: UIImage?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: QRReceivePaymentScreenInteractorInput,
       factory: QRReceivePaymentScreenFactoryInput,
       tokenModel: TokenModel) {
    self.interactor = interactor
    self.factory = factory
    self.stateTokenModel = tokenModel
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    interactor.getReplenishmentAddress()
    interactor.getQrImageWith(tokenModel: stateTokenModel)
  }
  
  // MARK: - Internal func
  
  func getDescriptionTitle() -> String {
    factory.createDescriptionTitle(
      tokenName: stateTokenModel.name,
      networkName: stateTokenModel.network.details.name
    )
  }
  
  func getMainButtonTitle() -> String {
    factory.createMainButtonTitle()
  }
  
  func getCopyButtonTitle() -> String {
    factory.createCopyButtonTitle()
  }
  
  func copyButtonAction() {
    interactor.copyToClipboard(text: stateReplenishmentAddress)
    interactor.showNotification(
      .positive(
        title: OChatStrings.QRReceivePaymentScreenLocalization
          .State.Notification.Copy.title
      )
    )
  }
  
  func shareQRReceivePaymentScreenTapped() {
    let name = "token_\(stateTokenModel.name)_network_\(stateTokenModel.network.details.name)"
    moduleOutput?.shareQRReceivePaymentScreenTapped(
      cacheQrImage,
      name: name
    )
  }
}

// MARK: - QRReceivePaymentScreenModuleInput

extension QRReceivePaymentScreenPresenter: QRReceivePaymentScreenModuleInput {}

// MARK: - QRReceivePaymentScreenInteractorOutput

extension QRReceivePaymentScreenPresenter: QRReceivePaymentScreenInteractorOutput {
  func didReceiveReplenishmentAddress(_ address: String) {
    stateReplenishmentAddress = address
  }
  
  func didReceiveQrImage(_ image: UIImage?) {
    cacheQrImage = image
    stateQrImage = Image(uiImage: image ?? UIImage())
  }
}

// MARK: - QRReceivePaymentScreenFactoryOutput

extension QRReceivePaymentScreenPresenter: QRReceivePaymentScreenFactoryOutput {}

// MARK: - SceneViewModel

extension QRReceivePaymentScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
    return .always
  }
}

// MARK: - Private

private extension QRReceivePaymentScreenPresenter {}

// MARK: - Constants

private enum Constants {}
