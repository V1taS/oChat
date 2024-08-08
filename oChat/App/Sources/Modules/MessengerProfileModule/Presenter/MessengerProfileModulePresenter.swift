//
//  MessengerProfileModulePresenter.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

final class MessengerProfileModulePresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateMyOnionAddress = ""
  @Published var stateQrImage: Image?
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MessengerProfileModuleModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: MessengerProfileModuleInteractorInput
  private let factory: MessengerProfileModuleFactoryInput
  private var cacheQrImage: UIImage?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: MessengerProfileModuleInteractorInput,
       factory: MessengerProfileModuleFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    interactor.getOnionAdress()
  }
  
  // MARK: - Internal func
  
  func getDescriptionTitle() -> String {
    factory.createDescriptionTitle()
  }
  
  func getCopyButtonTitle() -> String {
    factory.createCopyButtonTitle()
  }
  
  func copyButtonAction() {
    interactor.copyToClipboard(text: stateMyOnionAddress)
    interactor.showNotification(
      .positive(
        title: OChatStrings.MessengerProfileModuleLocalization
          .CopiedToClipboard.title
      )
    )
  }
  
  func shareQRReceivePaymentScreenTapped() {
    let name = "oChat_\(stateMyOnionAddress)"
    moduleOutput?.shareQRMessengerProfileScreenTapped(
      cacheQrImage,
      name: name
    )
  }
}

// MARK: - MessengerProfileModuleModuleInput

extension MessengerProfileModulePresenter: MessengerProfileModuleModuleInput {}

// MARK: - MessengerProfileModuleInteractorOutput

extension MessengerProfileModulePresenter: MessengerProfileModuleInteractorOutput {
  func didReceiveMyOnionAddress(_ address: String) {
    stateMyOnionAddress = address
    interactor.getQrImageWith(onionAdress: address)
  }
  
  func didReceiveQrImage(_ image: UIImage?) {
    cacheQrImage = image
    stateQrImage = Image(uiImage: image ?? UIImage())
  }
}

// MARK: - MessengerProfileModuleFactoryOutput

extension MessengerProfileModulePresenter: MessengerProfileModuleFactoryOutput {}

// MARK: - SceneViewModel

extension MessengerProfileModulePresenter: SceneViewModel {}

// MARK: - Private

private extension MessengerProfileModulePresenter {}

// MARK: - Constants

private enum Constants {}
