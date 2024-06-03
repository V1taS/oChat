//
//  MyWalletCustomizationScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `MyWalletCustomizationScreen`
public final class MyWalletCustomizationScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `MyWalletCustomizationScreen`
  /// - Returns: Cобранный модуль `MyWalletCustomizationScreen`
  public func createModule(_ walletModel: WalletModel, services: IApplicationServices) -> MyWalletCustomizationScreenModule {
    let interactor = MyWalletCustomizationScreenInteractor(services)
    let factory = MyWalletCustomizationScreenFactory()
    let presenter = MyWalletCustomizationScreenPresenter(
      interactor: interactor,
      factory: factory,
      walletModel
    )
    let view = MyWalletCustomizationScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
