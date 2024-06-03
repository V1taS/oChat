//
//  ImportWalletScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `ImportWalletScreen`
public final class ImportWalletScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `ImportWalletScreen`
  /// - Returns: Cобранный модуль `ImportWalletScreen`
  public func createModule(
    walletType: ImportWalletScreenType,
    services: IApplicationServices
  ) -> ImportWalletScreenModule {
    let interactor = ImportWalletScreenInteractor(services: services)
    let factory = ImportWalletScreenFactory()
    let presenter = ImportWalletScreenPresenter(
      interactor: interactor,
      factory: factory, 
      walletType
    )
    let view = ImportWalletScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
