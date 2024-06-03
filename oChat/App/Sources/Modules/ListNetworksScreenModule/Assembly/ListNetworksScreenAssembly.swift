//
//  ListNetworksScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `ListNetworksScreen`
public final class ListNetworksScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `ListNetworksScreen`
  /// - Returns: Cобранный модуль `ListNetworksScreen`
  public func createModule(_ tokenModel: TokenModel) -> ListNetworksScreenModule {
    let interactor = ListNetworksScreenInteractor()
    let factory = ListNetworksScreenFactory()
    let presenter = ListNetworksScreenPresenter(
      interactor: interactor,
      factory: factory, 
      tokenModel
    )
    let view = ListNetworksScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
