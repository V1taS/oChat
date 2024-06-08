//
//  MessengerNewMessengeScreenAssembly.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `MessengerNewMessengeScreen`
public final class MessengerNewMessengeScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `MessengerNewMessengeScreen`
  /// - Returns: Cобранный модуль `MessengerNewMessengeScreen`
  public func createModule(
    services: IApplicationServices,
    contactAdress: String?
  ) -> MessengerNewMessengeScreenModule {
    let interactor = MessengerNewMessengeScreenInteractor(services: services)
    let factory = MessengerNewMessengeScreenFactory()
    let presenter = MessengerNewMessengeScreenPresenter(
      interactor: interactor,
      factory: factory, 
      contactAdress: contactAdress
    )
    let view = MessengerNewMessengeScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
