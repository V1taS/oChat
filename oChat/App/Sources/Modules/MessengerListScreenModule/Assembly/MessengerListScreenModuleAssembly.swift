//
//  MessengerListScreenModuleAssembly.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `MessengerListScreenModule`
public final class MessengerListScreenModuleAssembly {

  /// Собирает модуль `MessengerListScreenModule`
  /// - Returns: Cобранный модуль `MessengerListScreenModule`
  public func createModule(
    services: IApplicationServices
  ) -> MessengerListScreenModuleModule {
    let interactor = MessengerListScreenModuleInteractor(services: services)
    let factory = MessengerListScreenModuleFactory()
    let presenter = MessengerListScreenModulePresenter(
      interactor: interactor,
      factory: factory
    )
    let view = MessengerListScreenModuleView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
  
  /// Собирает модуль для Демо `MessengerListScreenModule`
  /// - Returns: Cобранный модуль `MessengerListScreenModule`
  public func createMockModule(
    services: IApplicationServices
  ) -> MessengerListScreenModuleModule {
    let interactor = MessengerListScreenModuleMockInteractor(services: services)
    let factory = MessengerListScreenModuleFactory()
    let presenter = MessengerListScreenModulePresenter(
      interactor: interactor,
      factory: factory
    )
    let view = MessengerListScreenModuleView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
