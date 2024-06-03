//
//  ConfirmSendPaymentScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `ConfirmSendPaymentScreen`
public final class ConfirmSendPaymentScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `ConfirmSendPaymentScreen`
  /// - Returns: Cобранный модуль `ConfirmSendPaymentScreen`
  public func createModule(
    _ tokenModel: TokenModel,
    recipientAddress: String,
    services: IApplicationServices
  ) -> ConfirmSendPaymentScreenModule {
    let interactor = ConfirmSendPaymentScreenInteractor(services: services)
    let factory = ConfirmSendPaymentScreenFactory()
    let presenter = ConfirmSendPaymentScreenPresenter(
      interactor: interactor,
      factory: factory,
      tokenModel: tokenModel,
      recipientAddress: recipientAddress
    )
    let view = ConfirmSendPaymentScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
