//
//  IInterfaceManager.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 03.08.2024.
//

import Foundation

/// Протокол для управления интерфейсом приложения.
public protocol IInterfaceManager {
  /// Устанавливает красную точку на элемент TabBar.
  /// - Parameter value: Значение для отображения на красной точке (nil, если скрыть).
  func setRedDotToTabBar(value: String?)
}
