//
//  AuthenticationScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `AuthenticationScreen`
public final class AuthenticationScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `AuthenticationScreen`
  /// - Returns: Cобранный модуль `AuthenticationScreen`
  public func createModule(
    _ services: IApplicationServices,
    _ state: AuthenticationScreenState
  ) -> AuthenticationScreenModule {
    let interactor = AuthenticationScreenInteractor(services)
    let factory = AuthenticationScreenFactory()
    let presenter = AuthenticationScreenPresenter(
      interactor: interactor,
      factory: factory,
      state: state
    )
    let view = AuthenticationScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
