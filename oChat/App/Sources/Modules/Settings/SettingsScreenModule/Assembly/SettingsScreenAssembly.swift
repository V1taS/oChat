//
//  SettingsScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `SettingsScreen`
public final class SettingsScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `SettingsScreen`
  /// - Returns: Cобранный модуль `SettingsScreen`
  public func createModule(_ services: IApplicationServices) -> SettingsScreenModule {
    let interactor = SettingsScreenInteractor(services)
    let factory = SettingsScreenFactory()
    let presenter = SettingsScreenPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = SettingsScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
