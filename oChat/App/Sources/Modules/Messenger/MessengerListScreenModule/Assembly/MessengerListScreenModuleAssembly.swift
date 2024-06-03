//
//  MessengerListScreenModuleAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit

/// Сборщик `MessengerListScreenModule`
public final class MessengerListScreenModuleAssembly {
  private let messengerDialogModels: [MessengerDialogModel]

  public init(messengerDialogModels: [MessengerDialogModel]) {
    self.messengerDialogModels = messengerDialogModels
  }

  /// Собирает модуль `MessengerListScreenModule`
  /// - Returns: Cобранный модуль `MessengerListScreenModule`
  public func createModule() -> MessengerListScreenModuleModule {
    let interactor = MessengerListScreenModuleInteractor()
    let factory = MessengerListScreenModuleFactory(
      messengerDialogModels: messengerDialogModels
    )
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
