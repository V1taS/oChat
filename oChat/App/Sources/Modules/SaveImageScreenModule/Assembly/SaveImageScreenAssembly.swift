//
//  SaveImageScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 22.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `SaveImageScreen`
public final class SaveImageScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `SaveImageScreen`
  /// - Returns: Cобранный модуль `SaveImageScreen`
  public func createModule(_ walletModel: WalletModel) -> SaveImageScreenModule {
    let interactor = SaveImageScreenInteractor()
    let factory = SaveImageScreenFactory()
    let presenter = SaveImageScreenPresenter(
      interactor: interactor,
      factory: factory,
      walletModel
    )
    let view = SaveImageScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
