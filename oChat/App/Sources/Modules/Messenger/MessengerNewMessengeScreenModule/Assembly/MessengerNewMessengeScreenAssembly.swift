//
//  MessengerNewMessengeScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKUIKit

/// Сборщик `MessengerNewMessengeScreen`
public final class MessengerNewMessengeScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `MessengerNewMessengeScreen`
  /// - Returns: Cобранный модуль `MessengerNewMessengeScreen`
  public func createModule(senderName: String, costOfSendingMessage: String) -> MessengerNewMessengeScreenModule {
    let interactor = MessengerNewMessengeScreenInteractor()
    let factory = MessengerNewMessengeScreenFactory(senderName: senderName, costOfSendingMessage: costOfSendingMessage)
    let presenter = MessengerNewMessengeScreenPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = MessengerNewMessengeScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
