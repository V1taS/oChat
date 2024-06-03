//
//  ActivityScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit

/// Сборщик `ActivityScreen`
public final class ActivityScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `ActivityScreen`
  /// - Returns: Cобранный модуль `ActivityScreen`
  public func createModule() -> ActivityScreenModule {
    let interactor = ActivityScreenInteractor()
    let factory = ActivityScreenFactory()
    let presenter = ActivityScreenPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = ActivityScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
