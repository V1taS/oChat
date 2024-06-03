//
//  HighTechImageIDInfoSheetAssembly.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//

import SwiftUI
import SKUIKit

/// Сборщик `HighTechImageIDInfoSheet`
public final class HighTechImageIDInfoSheetAssembly {
  
  public init() {}
  
  /// Собирает модуль `HighTechImageIDInfoSheet`
  /// - Returns: Cобранный модуль `HighTechImageIDInfoSheet`
  public func createModule() -> HighTechImageIDInfoSheetModule {
    let interactor = HighTechImageIDInfoSheetInteractor()
    let factory = HighTechImageIDInfoSheetFactory()
    let presenter = HighTechImageIDInfoSheetPresenter(
      interactor: interactor,
      factory: factory
    )
    let view = HighTechImageIDInfoSheetView(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
