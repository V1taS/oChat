//
//  CreatePhraseWalletScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `CreatePhraseWalletScreen`
public final class CreatePhraseWalletScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `CreatePhraseWalletScreen`
  /// - Returns: Cобранный модуль `CreatePhraseWalletScreen`
  public func createModule(
    _ newWalletType: CreatePhraseWalletScreenType,
    _ services: IApplicationServices
  ) -> CreatePhraseWalletScreenModule {
    let interactor = CreatePhraseWalletScreenInteractor(services)
    let factory = CreatePhraseWalletScreenFactory()
    let presenter = CreatePhraseWalletScreenPresenter(
      interactor: interactor,
      factory: factory,
      newWalletType: newWalletType
    )
    let view = CreatePhraseWalletScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
