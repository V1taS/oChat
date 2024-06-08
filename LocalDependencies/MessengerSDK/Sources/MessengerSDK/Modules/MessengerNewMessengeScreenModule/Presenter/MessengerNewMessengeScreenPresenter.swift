//
//  MessengerNewMessengeScreenPresenter.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class MessengerNewMessengeScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var recipientAddress = ""
  @Published var stateMessengeModels: [MessengeModel] = []
  @Published var stateCostOfSendingMessage: String?
  
  // MARK: - Internal properties
  
  weak var moduleOutput: MessengerNewMessengeScreenModuleOutput?
  
  // MARK: - Private properties
  
  private var interactor: MessengerNewMessengeScreenInteractorInput
  private let factory: MessengerNewMessengeScreenFactoryInput
  
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - contactAdress: Контактный адрес
  init(interactor: MessengerNewMessengeScreenInteractorInput,
       factory: MessengerNewMessengeScreenFactoryInput,
       contactAdress: String?) {
    self.interactor = interactor
    self.factory = factory
    self.recipientAddress = contactAdress ?? ""
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
  
  func validateSendButton() -> Bool {
    !recipientAddress.isEmpty
  }
  
  func sendInitiateChat() {
    let address = recipientAddress
    interactor.showNotification(.positive(title: "Запрос на переписку отправлен"))
    
    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
      self?.moduleOutput?.sendInitiateChatFromNewMessenge(onionAddress: address)
    }
  }
}

// MARK: - MessengerNewMessengeScreenModuleInput

extension MessengerNewMessengeScreenPresenter: MessengerNewMessengeScreenModuleInput {}

// MARK: - MessengerNewMessengeScreenInteractorOutput

extension MessengerNewMessengeScreenPresenter: MessengerNewMessengeScreenInteractorOutput {}

// MARK: - MessengerNewMessengeScreenFactoryOutput

extension MessengerNewMessengeScreenPresenter: MessengerNewMessengeScreenFactoryOutput {}

// MARK: - SceneViewModel

extension MessengerNewMessengeScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var isEndEditing: Bool {
    true
  }
  
  var rightBarButtonItem: SKBarButtonItem? {
    .init(.close(action: { [weak self] in
      self?.moduleOutput?.closeNewMessengeScreenButtonTapped()
    }))
  }
}

// MARK: - Private

private extension MessengerNewMessengeScreenPresenter {}

// MARK: - Constants

private enum Constants {}
