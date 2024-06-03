//
//  MainScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit
import SKServices

/// Сборщик `MainScreen`
public final class MainScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `MainScreen`
  /// - Returns: Cобранный модуль `MainScreen`
  public func createModule() -> MainScreenModule {
    let interactor = MainScreenInteractor()
    let factory = MainScreenFactory()
    let presenter = MainScreenPresenter(
      interactor: interactor,
      factory: factory
    )
//    let view = MainScreenView(presenter: presenter)
    let view = ChatView()
    
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
