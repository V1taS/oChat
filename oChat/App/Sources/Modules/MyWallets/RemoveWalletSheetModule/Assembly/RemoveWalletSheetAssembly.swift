//
//  RemoveWalletSheetAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 09.05.2024.
//

import SwiftUI
import SKUIKit

/// Сборщик `RemoveWalletSheet`
public final class RemoveWalletSheetAssembly {
  
  public init() {}
  
  /// Собирает модуль `RemoveWalletSheet`
  /// - Returns: Cобранный модуль `RemoveWalletSheet`
  public func createModule() -> RemoveWalletSheetModule {
    let interactor = RemoveWalletSheetInteractor()
    let factory = RemoveWalletSheetFactory()
    let presenter = RemoveWalletSheetPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = RemoveWalletSheetView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
