//
//  QRReceivePaymentScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//

import SwiftUI
import SKUIKit
import SKAbstractions

/// Сборщик `QRReceivePaymentScreen`
public final class QRReceivePaymentScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `QRReceivePaymentScreen`
  /// - Returns: Cобранный модуль `QRReceivePaymentScreen`
  public func createModule(
    services: IApplicationServices,
    tokenModel: TokenModel
  ) -> QRReceivePaymentScreenModule {
    let interactor = QRReceivePaymentScreenInteractor(services)
    let factory = QRReceivePaymentScreenFactory()
    let presenter = QRReceivePaymentScreenPresenter(
      interactor: interactor,
      factory: factory,
      tokenModel: tokenModel
    )
    let view = QRReceivePaymentScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
