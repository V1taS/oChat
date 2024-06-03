//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import SwiftUI

/// Cобытия которые отправляем из Factory в Presenter
protocol ___FILEBASENAMEASIDENTIFIER___Output: AnyObject {}

/// Cобытия которые отправляем от Presenter к Factory
protocol ___FILEBASENAMEASIDENTIFIER___Input {}

/// Фабрика
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
