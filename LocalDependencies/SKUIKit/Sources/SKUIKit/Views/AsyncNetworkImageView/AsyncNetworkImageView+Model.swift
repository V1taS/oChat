//
//  AsyncNetworkImageView+Model.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 17.05.2024.
//

import Foundation

// MARK: - Model

extension AsyncNetworkImageView {
  /// Модель данных для асинхронного сетевого изображения.
  public struct Model {
    /// URL изображения.
    public let imageUrl: URL?
    
    /// Размер изображения.
    public let size: CGSize
    
    /// Тип закругления углов для изображения.
    public let cornerRadiusType: CornerRadiusType
    
    // MARK: - Init
    
    /// Публичный инициализатор для создания модели данных.
    ///
    /// - Parameters:
    ///   - imageUrl: URL изображения.
    ///   - size: Размер изображения.
    ///   - cornerRadiusType: Тип закругления углов для изображения.
    public init(
      imageUrl: URL?,
      size: CGSize,
      cornerRadiusType: CornerRadiusType
    ) {
      self.imageUrl = imageUrl
      self.size = size
      self.cornerRadiusType = cornerRadiusType
    }
  }
}

// MARK: - CornerRadiusType

extension AsyncNetworkImageView {
  /// Тип закругления углов для изображения.
  public enum CornerRadiusType {
    /// Без закругления углов.
    case none
    
    /// Закругленные углы с указанным радиусом.
    /// - Parameter radius: Радиус закругления углов.
    case rounded(CGFloat)
    
    /// Круглая форма (для квадратных изображений).
    case circle
    
    /// Сквиркл (компромисс между кругом и квадратом).
    case squircle
    
    /// Возвращает радиус закругления углов в зависимости от типа.
    /// - Parameter size: Размер изображения.
    /// - Returns: Радиус закругления углов.
    public func cornerRadius(for size: CGSize) -> CGFloat {
      switch self {
      case .none:
        return .zero
      case let .rounded(radius):
        return radius
      case .circle:
        return min(size.width, size.height) / 2
      case .squircle:
        return min(size.width, size.height) / 4
      }
    }
  }
}

// MARK: - ImageLoadState


extension AsyncNetworkImageView {
  enum ImageLoadState {
    /// Изображение в процессе загрузки.
    case loading
    
    /// Изображение успешно загружено.
    case success
    
    /// Произошла ошибка при загрузке изображения.
    case failure
  }
}
