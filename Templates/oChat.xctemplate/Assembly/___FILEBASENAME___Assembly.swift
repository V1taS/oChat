//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import SwiftUI
import SKUIKit

/// Сборщик `___VARIABLE_productName___`
public final class ___FILEBASENAMEASIDENTIFIER___ {
  
  public init() {}
  
  /// Собирает модуль `___VARIABLE_productName___`
  /// - Returns: Cобранный модуль `___VARIABLE_productName___`
  public func createModule() -> ___VARIABLE_productName___Module {
    let interactor = ___VARIABLE_productName___Interactor()
    let factory = ___VARIABLE_productName___Factory()
    let presenter = ___VARIABLE_productName___Presenter(
      interactor: interactor,
      factory: factory
    )
    let view = ___VARIABLE_productName___View(presenter: presenter)
    let viewController = SceneViewController(viewModel: presenter, content: view)
    
    interactor.output = presenter
    factory.output = presenter
    return (viewController: viewController, input: presenter)
  }
}
