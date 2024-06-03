//
//  HighTechImageIDScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `HighTechImageIDScreen`
public final class HighTechImageIDScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `HighTechImageIDScreen`
  /// - Returns: Cобранный модуль `HighTechImageIDScreen`
  public func createModule(
    state: HighTechImageIDScreenState,
    services: IApplicationServices,
    walletModel: WalletModel?
  ) -> HighTechImageIDScreenModule {
    let interactor = HighTechImageIDScreenInteractor(services)
    let factory = HighTechImageIDScreenFactory()
    let presenter = HighTechImageIDScreenPresenter(
      interactor: interactor,
      factory: factory,
      state: state, 
      walletModel: walletModel
    )
    let view = HighTechImageIDScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
