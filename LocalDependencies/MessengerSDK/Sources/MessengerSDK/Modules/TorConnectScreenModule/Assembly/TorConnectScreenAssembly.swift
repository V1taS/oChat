//
//  TorConnectScreenAssembly.swift
//  MessengerSDK
//
//  Created by Vitalii Sosin on 07.06.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `TorConnectScreen`
public final class TorConnectScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `TorConnectScreen`
  /// - Returns: Cобранный модуль `TorConnectScreen`
  public func createModule(services: IApplicationServices) -> TorConnectScreenModule {
    let interactor = TorConnectScreenInteractor(services)
    let factory = TorConnectScreenFactory()
    let presenter = TorConnectScreenPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = TorConnectScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
