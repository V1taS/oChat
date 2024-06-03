//
//  ListTokensScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 25.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `ListTokensScreen`
public final class ListTokensScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `ListTokensScreen`
  /// - Returns: Cобранный модуль `ListTokensScreen`
  public func createModule(screenType: ListTokensScreenType) -> ListTokensScreenModule {
    let interactor = ListTokensScreenInteractor()
    let factory = ListTokensScreenFactory()
    let presenter = ListTokensScreenPresenter(
      interactor: interactor,
      factory: factory, 
      screenType: screenType
    )
    let view = ListTokensScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
