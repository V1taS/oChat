//
//  MyNewWalletSheetAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SwiftUI
import SKUIKit

/// Сборщик `MyNewWalletSheet`
public final class MyNewWalletSheetAssembly {
  
  public init() {}
  
  /// Собирает модуль `MyNewWalletSheet`
  /// - Returns: Cобранный модуль `MyNewWalletSheet`
  public func createModule() -> MyNewWalletSheetModule {
    let interactor = MyNewWalletSheetInteractor()
    let factory = MyNewWalletSheetFactory()
    let presenter = MyNewWalletSheetPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = MyNewWalletSheetView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
