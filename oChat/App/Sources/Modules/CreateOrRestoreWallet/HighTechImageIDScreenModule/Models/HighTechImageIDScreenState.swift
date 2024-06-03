//
//  HighTechImageIDScreenState.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKUIKit

// MARK: - HighTechImageIDScreenState

public enum HighTechImageIDScreenState: Equatable {
  case generateImageID(StateScreen)
  case loginImageID(StateScreen)
  
  public enum StateScreen: Equatable {
    /// Начальное состояние
    case initialState
    /// Ввод код доступа для изображения
    case passCodeImage
    /// Первый экран для загрузки изображения
    case startUploadImage
    /// Изображение загружено
    case finish
  }
}

// MARK: - Mapping HighTechImageIDScreenState

extension HighTechImageIDScreenState {
  func mapTo() -> HighTechImageIDView.ImageState {
    let state: HighTechImageIDView.ImageState
    switch self {
    case let .generateImageID(result), let .loginImageID(result):
      switch result {
      case .initialState, .passCodeImage:
        state = .initial
      case .startUploadImage:
        state = .uploadingImage
      case .finish:
        state = .uploadedImage
      }
    }
    return state
  }
}
