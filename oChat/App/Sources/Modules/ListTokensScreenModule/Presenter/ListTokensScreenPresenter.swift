//
//  ListTokensScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 25.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class ListTokensScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateScreenType: ListTokensScreenType
  @Published var stateSelectedTokenModel: TokenModel?
  @Published var stateListTokenModels: [TokenModel] = []
  @Published var stateWidgetCryptoModels: [WidgetCryptoView.Model] = []
  @Published var stateSearchText: String = ""
  
  // MARK: - Internal properties
  
  weak var moduleOutput: ListTokensScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: ListTokensScreenInteractorInput
  private let factory: ListTokensScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - screenType: Тип экрана
  init(interactor: ListTokensScreenInteractorInput,
       factory: ListTokensScreenFactoryInput,
       screenType: ListTokensScreenType) {
    self.interactor = interactor
    self.factory = factory
    
    switch screenType {
    case let .tokenSelectioList(tokenModel):
      self.stateSelectedTokenModel = tokenModel
    case let .addTokenOnMainScreen(tokenModels):
      self.stateListTokenModels = tokenModels
    }
    self.stateScreenType = screenType
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = { [weak self] in
    guard let self else {
      return
    }
    
    switch stateScreenType {
      
    case .tokenSelectioList:
      interactor.getListTokens()
    case .addTokenOnMainScreen:
      getContent()
    }
  }
  
  // MARK: - Internal func
}

// MARK: - ListTokensScreenModuleInput

extension ListTokensScreenPresenter: ListTokensScreenModuleInput {}

// MARK: - ListTokensScreenInteractorOutput

extension ListTokensScreenPresenter: ListTokensScreenInteractorOutput {
  func didReceiveTokens(_ tokens: [SKAbstractions.TokenModel]) {
    stateListTokenModels = tokens
    
    if stateSelectedTokenModel == nil {
      stateSelectedTokenModel = tokens.first
    }
    getContent()
  }
}

// MARK: - ListTokensScreenFactoryOutput

extension ListTokensScreenPresenter: ListTokensScreenFactoryOutput {
  func tokenSelected(_ model: SKAbstractions.TokenModel) {
    moduleOutput?.tokenSelected(model)
  }
  
  func tokenIsActive(_ model: SKAbstractions.TokenModel, value: Bool) {
    if let tokenIndex = stateListTokenModels.firstIndex(where: { $0.id == model.id }) {
      let newTokenModel = TokenModel(
        name: model.name,
        ticker: model.ticker,
        address: model.address,
        decimals: model.decimals,
        eip2612: model.eip2612,
        isFeeOnTransfer: model.isFeeOnTransfer,
        network: model.network,
        availableNetworks: model.availableNetworks,
        tokenAmount: model.tokenAmount,
        currency: model.currency,
        isActive: value,
        logoURI: model.imageTokenURL?.absoluteString
      )
      
      stateListTokenModels.remove(at: tokenIndex)
      stateListTokenModels.insert(newTokenModel, at: tokenIndex)
      getContent()
    }
    moduleOutput?.tokensIsActived(stateListTokenModels)
  }
}

// MARK: - SceneViewModel

extension ListTokensScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    factory.createHeaderTitle(stateScreenType)
  }
}

// MARK: - Private

private extension ListTokensScreenPresenter {
  func getContent() {
    switch stateScreenType {
    case .tokenSelectioList:
      stateWidgetCryptoModels = factory.createTokenSelectioList(
        listTokenModels: stateListTokenModels
      )
    case .addTokenOnMainScreen:
      stateWidgetCryptoModels = factory.createAddTokenOnMainScreenList(
        listTokenModels: stateListTokenModels
      )
    }
  }
}

// MARK: - Constants

private enum Constants {}
