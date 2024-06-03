//
//  TransactionInformationSheetAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 07.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `TransactionInformationSheet`
public final class TransactionInformationSheetAssembly {
  
  public init() {}
  
  /// Собирает модуль `TransactionInformationSheet`
  /// - Returns: Cобранный модуль `TransactionInformationSheet`
  public func createModule(
    model: TransactionModel,
    services: IApplicationServices
  ) -> TransactionInformationSheetModule {
    let interactor = TransactionInformationSheetInteractor(services: services)
    let factory = TransactionInformationSheetFactory()
    let presenter = TransactionInformationSheetPresenter(
      interactor: interactor,
      factory: factory,
      model
    )
    let view = TransactionInformationSheetView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
