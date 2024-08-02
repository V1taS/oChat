//
//  MessengerProfileModuleAssembly.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 06.06.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `MessengerProfileModule`
public final class MessengerProfileModuleAssembly {
  
  public init() {}
  
  /// Собирает модуль `MessengerProfileModule`
  /// - Returns: Cобранный модуль `MessengerProfileModule`
  public func createModule(services: IApplicationServices) -> MessengerProfileModule {
    let interactor = MessengerProfileModuleInteractor(services)
    let factory = MessengerProfileModuleFactory()
    let presenter = MessengerProfileModulePresenter(
      interactor: interactor,
      factory: factory
    )
    let view = MessengerProfileModuleView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
