//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import SwiftUI

/// События которые отправляем из Interactor в Presenter
protocol ___FILEBASENAMEASIDENTIFIER___Output: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol ___FILEBASENAMEASIDENTIFIER___Input {}

/// Интерактор
final class ___FILEBASENAMEASIDENTIFIER___ {
  
  // MARK: - Internal properties
  
  weak var output: ___FILEBASENAMEASIDENTIFIER___Output?
}

// MARK: - ___FILEBASENAMEASIDENTIFIER___Input

extension ___FILEBASENAMEASIDENTIFIER___: ___FILEBASENAMEASIDENTIFIER___Input {}

// MARK: - Private

private extension ___FILEBASENAMEASIDENTIFIER___ {}

// MARK: - Constants

private enum Constants {}
