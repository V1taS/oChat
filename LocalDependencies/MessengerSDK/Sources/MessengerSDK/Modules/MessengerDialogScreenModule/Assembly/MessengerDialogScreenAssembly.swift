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
  public func createModule(
    dialogModel: ContactModel,
    services: IApplicationServices
  ) -> MessengerDialogScreenModule {
    let interactor = MessengerDialogScreenInteractor(services: services)
    let factory = MessengerDialogScreenFactory()
    let presenter = MessengerDialogScreenPresenter(
      interactor: interactor,
      factory: factory, dialogModel: dialogModel
    )
    let view = MessengerDialogScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
