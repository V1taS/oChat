//
//  PasscodeSettingsScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `PasscodeSettingsScreen`
public final class PasscodeSettingsScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `PasscodeSettingsScreen`
  /// - Returns: Cобранный модуль `PasscodeSettingsScreen`
  public func createModule(_ services: IApplicationServices) -> PasscodeSettingsScreenModule {
    let interactor = PasscodeSettingsScreenInteractor(services)
    let factory = PasscodeSettingsScreenFactory()
    let presenter = PasscodeSettingsScreenPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = PasscodeSettingsScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
