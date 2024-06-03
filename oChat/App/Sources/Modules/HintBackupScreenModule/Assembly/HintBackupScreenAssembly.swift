//
//  HintBackupScreenAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//

import SwiftUI
import SKUIKit

/// Сборщик `HintBackupScreen`
public final class HintBackupScreenAssembly {
  
  public init() {}
  
  /// Собирает модуль `HintBackupScreen`
  /// - Returns: Cобранный модуль `HintBackupScreen`
  public func createModule(_ hintType: HintBackupScreenType) -> HintBackupScreenModule {
    let interactor = HintBackupScreenInteractor()
    let factory = HintBackupScreenFactory()
    let presenter = HintBackupScreenPresenter(
      interactor: interactor,
      factory: factory,
      hintType: hintType
    )
    let view = HintBackupScreenView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
