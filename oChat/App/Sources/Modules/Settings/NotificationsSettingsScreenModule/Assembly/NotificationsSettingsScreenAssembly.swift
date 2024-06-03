//
//  NotificationsSettingsScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `NotificationsSettingsScreen`
public final class NotificationsSettingsScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `NotificationsSettingsScreen`
  /// - Returns: Cобранный модуль `NotificationsSettingsScreen`
  public func createModule(_ services: IApplicationServices) -> NotificationsSettingsScreenModule {
    let interactor = NotificationsSettingsScreenInteractor(services)
    let factory = NotificationsSettingsScreenFactory()
    let presenter = NotificationsSettingsScreenPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = NotificationsSettingsScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
