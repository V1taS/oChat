//
//  ReceivePaymentScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//

import SwiftUI
import SKUIKit

/// Сборщик `ReceivePaymentScreen`
public final class ReceivePaymentScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `ReceivePaymentScreen`
  /// - Returns: Cобранный модуль `ReceivePaymentScreen`
  public func createModule() -> ReceivePaymentScreenModule {
    let interactor = ReceivePaymentScreenInteractor()
    let factory = ReceivePaymentScreenFactory()
    let presenter = ReceivePaymentScreenPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = ReceivePaymentScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
