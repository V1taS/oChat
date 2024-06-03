//
//  SendPaymentScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `SendPaymentScreen`
public final class SendPaymentScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `SendPaymentScreen`
  /// - Returns: Cобранный модуль `SendPaymentScreen`
  public func createModule(
    _ screenModel: SendPaymentScreenModel,
    _ services: IApplicationServices
  ) -> SendPaymentScreenModule {
    let interactor = SendPaymentScreenInteractor(services)
    let factory = SendPaymentScreenFactory()
    let presenter = SendPaymentScreenPresenter(
      interactor: interactor,
      factory: factory,
      screenModel: screenModel
    )
    let view = SendPaymentScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
