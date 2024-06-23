//
//  RoundedCornerShape.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 23.06.2024.
//

import SwiftUI

/// `RoundedCornerShape` - это структура, реализующая протокол `Shape`,
/// которая позволяет создавать фигуры с закругленными углами.
///
/// Пример использования:
/// ```
/// .clipShape(RoundedCornerShape(corners: [.bottomLeft, .bottomRight], radius: .s4))
/// ```
public struct RoundedCornerShape: Shape {
  /// Углы, которые необходимо закруглить.
  private var corners: UIRectCorner
  
  /// Радиус закругления углов.
  private var radius: CGFloat
  
  /// Инициализатор для создания фигуры с закругленными углами.
  ///
  /// - Parameters:
  ///   - corners: Углы, которые должны быть закруглены. Можно указать несколько углов, используя опции `UIRectCorner`.
  ///   - radius: Радиус закругления углов. Чем больше значение, тем сильнее закругление.
  public init(corners: UIRectCorner, radius: CGFloat) {
    self.corners = corners
    self.radius = radius
  }
  
  /// Создает и возвращает путь, представляющий фигуру с закругленными углами.
  ///
  /// - Parameter rect: Прямоугольник, в пределах которого будет нарисована фигура.
  /// - Returns: Путь (`Path`), представляющий фигуру с закругленными углами.
  public func path(in rect: CGRect) -> Path {
    // Создаем UIBezierPath с закругленными углами.
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    // Преобразуем UIBezierPath в SwiftUI Path и возвращаем его.
    return Path(path.cgPath)
  }
}
