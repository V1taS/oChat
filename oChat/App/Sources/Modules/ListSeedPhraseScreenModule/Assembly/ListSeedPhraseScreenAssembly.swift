//
//  ListSeedPhraseScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `ListSeedPhraseScreen`
public final class ListSeedPhraseScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `ListSeedPhraseScreen`
  /// - Returns: Cобранный модуль `ListSeedPhraseScreen`
  public func createModule(
    services: IApplicationServices,
    screenType: ListSeedPhraseScreenType,
    walletModel: WalletModel
  ) -> ListSeedPhraseScreenModule {
    let interactor = ListSeedPhraseScreenInteractor(services)
    let factory = ListSeedPhraseScreenFactory()
    let presenter = ListSeedPhraseScreenPresenter(
      interactor: interactor,
      factory: factory,
      screenType: screenType,
      walletModel: walletModel
    )
    let view = ListSeedPhraseScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
