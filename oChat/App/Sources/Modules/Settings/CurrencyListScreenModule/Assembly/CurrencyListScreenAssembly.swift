//
//  CurrencyListScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `CurrencyListScreen`
public final class CurrencyListScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `CurrencyListScreen`
  /// - Returns: Cобранный модуль `CurrencyListScreen`
  public func createModule(_ services: IApplicationServices) -> CurrencyListScreenModule {
    let interactor = CurrencyListScreenInteractor(services)
    let factory = CurrencyListScreenFactory()
    let presenter = CurrencyListScreenPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = CurrencyListScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
