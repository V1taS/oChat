//
//  InitialScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `InitialScreen`
public final class InitialScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `InitialScreen`
  /// - Returns: Cобранный модуль `InitialScreen`
  public func createModule(_ services: IApplicationServices) -> InitialScreenModule {
    let interactor = InitialScreenInteractor(services)
    let factory = InitialScreenFactory()
    let presenter = InitialScreenPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = InitialScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
