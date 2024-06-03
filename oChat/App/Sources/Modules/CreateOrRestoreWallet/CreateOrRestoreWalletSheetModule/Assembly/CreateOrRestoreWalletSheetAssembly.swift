//
//  CreateOrRestoreWalletSheetAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//

import SwiftUI
import SKUIKit

/// Сборщик `CreateOrRestoreWalletSheet`
public final class CreateOrRestoreWalletSheetAssembly {
  
  public init() {}
  
  /// Собирает модуль `CreateOrRestoreWalletSheet`
  /// - Returns: Cобранный модуль `CreateOrRestoreWalletSheet`
  public func createModule(
    sheetType: CreateOrRestoreWalletSheetType
  ) -> CreateOrRestoreWalletSheetModule {
    let interactor = CreateOrRestoreWalletSheetInteractor()
    let factory = CreateOrRestoreWalletSheetFactory()
    let presenter = CreateOrRestoreWalletSheetPresenter(
      interactor: interactor,
      factory: factory,
      sheetType: sheetType
    )
    let view = CreateOrRestoreWalletSheetView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
