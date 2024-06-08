//
//  ITouchWindow.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 11.05.2024.
//

import Foundation
import UIKit

/// Протокол для окон, перехватывающих события касания.
public protocol ITouchWindow {
  // MARK: - Properties
  
  /// Обработчик событий, вызываемый при каждом касании.
  var didSendEvent: ((_ event: UIEvent?) -> Void)? { get set }
}
