//
//  ListNetworksScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class ListNetworksScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateSearchText: String = ""
  @Published var stateWidgetModels: [WidgetCryptoView.Model] = []
  @Published var stateListNetworks: [TokenNetworkType] = []
  @Published var stateCurrentNetwork: TokenNetworkType = .ethereum
  
  // MARK: - Internal properties
  
  weak var moduleOutput: ListNetworksScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: ListNetworksScreenInteractorInput
  private let factory: ListNetworksScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - tokenModel: Модель токена
  init(interactor: ListNetworksScreenInteractorInput,
       factory: ListNetworksScreenFactoryInput,
       _ tokenModel: TokenModel) {
    self.interactor = interactor
    self.factory = factory
    self.stateListNetworks = tokenModel.availableNetworks
    self.stateCurrentNetwork = tokenModel.network
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    
    stateWidgetModels = factory.createNetworkSelectioList(
      currentNetwork: stateCurrentNetwork,
      stateListNetworks
    )
  }
  
  // MARK: - Internal func
}

// MARK: - ListNetworksScreenModuleInput

extension ListNetworksScreenPresenter: ListNetworksScreenModuleInput {}

// MARK: - ListNetworksScreenInteractorOutput

extension ListNetworksScreenPresenter: ListNetworksScreenInteractorOutput {}

// MARK: - ListNetworksScreenFactoryOutput

extension ListNetworksScreenPresenter: ListNetworksScreenFactoryOutput {
  func networkSelected(_ model: SKAbstractions.TokenNetworkType) {
    moduleOutput?.networkSelected(model)
  }
}

// MARK: - SceneViewModel

extension ListNetworksScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle()
  }
}

// MARK: - Private

private extension ListNetworksScreenPresenter {}

// MARK: - Constants

private enum Constants {}
