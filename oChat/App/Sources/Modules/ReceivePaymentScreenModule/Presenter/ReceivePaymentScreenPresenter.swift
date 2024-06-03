//
//  ReceivePaymentScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class ReceivePaymentScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateTokenModel: TokenModel = .ethereumMock
  @Published var stateWidgetModels: [ReceivePaymentScreenModel] = []
  
  // MARK: - Internal properties
  
  weak var moduleOutput: ReceivePaymentScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: ReceivePaymentScreenInteractorInput
  private let factory: ReceivePaymentScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: ReceivePaymentScreenInteractorInput,
       factory: ReceivePaymentScreenFactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    interactor.getTokenModel()
  }
  
  // MARK: - Internal func
  
  func getButtonTitle() -> String {
    factory.createButtonTitle()
  }
}

// MARK: - ReceivePaymentScreenModuleInput

extension ReceivePaymentScreenPresenter: ReceivePaymentScreenModuleInput {
  func updateNetwork(_ model: SKAbstractions.TokenNetworkType) {
    let tokenModel = factory.updateTokenModelWith(model, tokenModel: stateTokenModel)
    updateData(tokenModel)
  }
  
  func updateTokenModel(_ model: SKAbstractions.TokenModel) {
    updateData(model)
  }
}

// MARK: - ReceivePaymentScreenInteractorOutput

extension ReceivePaymentScreenPresenter: ReceivePaymentScreenInteractorOutput {
  func didReceiveTokenModel(_ model: SKAbstractions.TokenModel) {
    updateData(model)
  }
}

// MARK: - ReceivePaymentScreenFactoryOutput

extension ReceivePaymentScreenPresenter: ReceivePaymentScreenFactoryOutput {
  func openNetworkSelectionScreen() {
    moduleOutput?.openNetworkSelectionScreen(stateTokenModel)
  }
  
  func openListTokensScreen() {
    moduleOutput?.openListTokensScreen(stateTokenModel)
  }
}

// MARK: - SceneViewModel

extension ReceivePaymentScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
  
  var leftBarButtonItem: SKBarButtonItem? {
    .init(.close(action: { [weak self] in
      self?.moduleOutput?.closeReceivePaymentScreenButtonTapped()
    }))
  }
  
  var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode {
    return .always
  }
}

// MARK: - Private

private extension ReceivePaymentScreenPresenter {
  func updateData(_ model: SKAbstractions.TokenModel) {
    stateTokenModel = model
    stateWidgetModels = factory.createWidgetModels(model)
  }
}

// MARK: - Constants

private enum Constants {}
