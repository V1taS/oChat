//
//  MessengerDialogScreenAssembly.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `MessengerDialogScreen`
public final class MessengerDialogScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `MessengerDialogScreen`
  /// - Returns: Cобранный модуль `MessengerDialogScreen`
  @MainActor
  public func createModule(
    contactModel: ContactModel?,
    contactAdress: String?,
    services: IApplicationServices
  ) async -> MessengerDialogScreenModule {
    let interactor = MessengerDialogScreenInteractor(services: services)
    let factory = MessengerDialogScreenFactory()
    let presenter = await MessengerDialogScreenPresenter(
      interactor: interactor,
      factory: factory, 
      contactModel: contactModel,
      contactAdress: contactAdress
    )
    let view = MessengerDialogScreenView(presenter: presenter)
    let viewController = await SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
