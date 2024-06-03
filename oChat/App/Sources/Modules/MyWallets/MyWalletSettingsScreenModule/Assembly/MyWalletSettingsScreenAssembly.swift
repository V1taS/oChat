//
//  MyWalletSettingsScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `MyWalletSettingsScreen`
public final class MyWalletSettingsScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `MyWalletSettingsScreen`
  /// - Returns: Cобранный модуль `MyWalletSettingsScreen`
  public func createModule(
    services: IApplicationServices,
    walletModel: WalletModel
  ) -> MyWalletSettingsScreenModule {
    let interactor = MyWalletSettingsScreenInteractor(services)
    let factory = MyWalletSettingsScreenFactory()
    let presenter = MyWalletSettingsScreenPresenter(
      interactor: interactor,
      factory: factory, 
      walletModel: walletModel
    )
    let view = MyWalletSettingsScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
