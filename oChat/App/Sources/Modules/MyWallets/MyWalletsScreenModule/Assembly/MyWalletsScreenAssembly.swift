//
//  MyWalletsScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `MyWalletsScreen`
public final class MyWalletsScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `MyWalletsScreen`
  /// - Returns: Cобранный модуль `MyWalletsScreen`
  public func createModule(_ services: IApplicationServices) -> MyWalletsScreenModule {
    let interactor = MyWalletsScreenInteractor(services)
    let factory = MyWalletsScreenFactory()
    let presenter = MyWalletsScreenPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = MyWalletsScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
