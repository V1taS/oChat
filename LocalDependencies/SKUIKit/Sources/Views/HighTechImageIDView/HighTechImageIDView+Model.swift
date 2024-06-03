//
//  HighTechImageIDView+Model.swift
//
//
//  Created by Vitalii Sosin on 25.02.2024.
//

import SwiftUI

// MARK: - Model

extension HighTechImageIDView {
  public struct Model {
    
    // MARK: - Public properties
    
    public let image: Image?
    public let imageState: ImageState
    public let action: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Инициализатор
    /// - Parameters:
    ///   - image: Изображение
    ///   - imageState: Состояние изображения
    ///   - action: Экшен на нажатие изображения
    public init(
      image: Image?,
      imageState: ImageState,
      action: (() -> Void)? = nil
    ) {
      self.image = image
      self.imageState = imageState
      self.action = action
    }
  }
}

// MARK: - Model

extension HighTechImageIDView {
  public enum ImageState: Equatable {
    /// Первоначальное состояние
    case initial
    /// Загружаются картинки
    case uploadingImage
    /// Картинка загружена
    case uploadedImage
  }
}
