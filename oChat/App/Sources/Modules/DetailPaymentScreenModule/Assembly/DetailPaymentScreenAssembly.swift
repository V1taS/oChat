//
//  DetailPaymentScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 05.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `DetailPaymentScreen`
public final class DetailPaymentScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `DetailPaymentScreen`
  /// - Returns: Cобранный модуль `DetailPaymentScreen`
  public func createModule(tokenModel: TokenModel) -> DetailPaymentScreenModule {
    let interactor = DetailPaymentScreenInteractor()
    let factory = DetailPaymentScreenFactory()
    let presenter = DetailPaymentScreenPresenter(
      interactor: interactor,
      factory: factory, 
      tokenModel: tokenModel
    )
    let view = DetailPaymentScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
