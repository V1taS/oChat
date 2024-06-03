//
//  SuggestScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `SuggestScreen`
public final class SuggestScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `SuggestScreen`
  /// - Returns: Cобранный модуль `SuggestScreen`
  public func createModule(
    _ state: SuggestScreenState,
    services: IApplicationServices
  ) -> SuggestScreenModule {
    let interactor = SuggestScreenInteractor(services: services)
    let factory = SuggestScreenFactory()
    let presenter = SuggestScreenPresenter(
      interactor: interactor,
      factory: factory,
      state
    )
    let view = SuggestScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
