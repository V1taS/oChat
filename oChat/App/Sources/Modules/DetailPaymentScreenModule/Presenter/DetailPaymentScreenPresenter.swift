//
//  DetailPaymentScreenPresenter.swift
//  oChat
//
//  Created by Vitalii Sosin on 05.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

final class DetailPaymentScreenPresenter: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateTokenModel: TokenModel
  @Published var stateListActivity: [DetailPaymentScreenModel] = []
  
  // MARK: - Internal properties
  
  weak var moduleOutput: DetailPaymentScreenModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: DetailPaymentScreenInteractorInput
  private let factory: DetailPaymentScreenFactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  ///   - tokenModel: Модель токена
  init(interactor: DetailPaymentScreenInteractorInput,
       factory: DetailPaymentScreenFactoryInput,
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
    stateListActivity = factory.createListActivity()
  }
  
  // MARK: - Internal func
  
  func getButtonSendTitle() -> String {
    factory.createButtonSendTitle()
  }
  
  func getButtonReceiveTitle() -> String {
    factory.createButtonReceiveTitle()
  }
}

// MARK: - DetailPaymentScreenModuleInput

extension DetailPaymentScreenPresenter: DetailPaymentScreenModuleInput {}

// MARK: - DetailPaymentScreenInteractorOutput

extension DetailPaymentScreenPresenter: DetailPaymentScreenInteractorOutput {}

// MARK: - DetailPaymentScreenFactoryOutput

extension DetailPaymentScreenPresenter: DetailPaymentScreenFactoryOutput {
  func openTransactionInformationSheet(_ tokenModel: SKAbstractions.TokenModel) {
    moduleOutput?.openTransactionInformationSheet(tokenModel)
  }
}

// MARK: - SceneViewModel

extension DetailPaymentScreenPresenter: SceneViewModel {
  var sceneTitle: String? {
    stateTokenModel.name
  }
}

// MARK: - Private

private extension DetailPaymentScreenPresenter {}

// MARK: - Constants

private enum Constants {}
