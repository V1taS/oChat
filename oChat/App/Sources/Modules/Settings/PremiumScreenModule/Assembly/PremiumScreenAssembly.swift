//
//  PremiumScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 15.08.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `PremiumScreen`
public final class PremiumScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `PremiumScreen`
  /// - Returns: Cобранный модуль `PremiumScreen`
  public func createModule(_ services: IApplicationServices) -> PremiumScreenModule {
    let interactor = PremiumScreenInteractor(services)
    let factory = PremiumScreenFactory()
    let presenter = PremiumScreenPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = PremiumScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
