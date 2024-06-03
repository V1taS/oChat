//
//  AppearanceAppScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `AppearanceAppScreen`
public final class AppearanceAppScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `AppearanceAppScreen`
  /// - Returns: Cобранный модуль `AppearanceAppScreen`
  public func createModule(_ services: IApplicationServices) -> AppearanceAppScreenModule {
    let interactor = AppearanceAppScreenInteractor(services)
    let factory = AppearanceAppScreenFactory()
    let presenter = AppearanceAppScreenPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = AppearanceAppScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
