//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import SKStyle
import SKUIKit
import SwiftUI

final class ___FILEBASENAMEASIDENTIFIER___: ObservableObject {
  
  // MARK: - View state
  
  @Published var stateButtonTitle = "Продолжить"
  
  // MARK: - Internal properties
  
  weak var moduleOutput: ___VARIABLE_productName___ModuleOutput?
  
  // MARK: - Private properties
  
  private let interactor: ___VARIABLE_productName___InteractorInput
  private let factory: ___VARIABLE_productName___FactoryInput
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - interactor: Интерактор
  ///   - factory: Фабрика
  init(interactor: ___VARIABLE_productName___InteractorInput,
       factory: ___VARIABLE_productName___FactoryInput) {
    self.interactor = interactor
    self.factory = factory
  }
  
  // MARK: - The lifecycle of a UIViewController
  
  lazy var viewDidLoad: (() -> Void)? = {}
  
  // MARK: - Internal func
}

// MARK: - ___VARIABLE_productName___ModuleInput

extension ___FILEBASENAMEASIDENTIFIER___: ___VARIABLE_productName___ModuleInput {}

// MARK: - ___VARIABLE_productName___InteractorOutput

extension ___FILEBASENAMEASIDENTIFIER___: ___VARIABLE_productName___InteractorOutput {}

// MARK: - ___VARIABLE_productName___FactoryOutput

extension ___FILEBASENAMEASIDENTIFIER___: ___VARIABLE_productName___FactoryOutput {}

// MARK: - SceneViewModel

extension ___FILEBASENAMEASIDENTIFIER___: SceneViewModel {}

// MARK: - Private

private extension ___FILEBASENAMEASIDENTIFIER___ {}

// MARK: - Constants

private enum Constants {}
