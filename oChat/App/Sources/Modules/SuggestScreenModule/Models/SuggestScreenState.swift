//
//  SuggestScreenState.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation

// MARK: - SuggestScreenState

public enum SuggestScreenState: Equatable {
  /// Предложить установить код доступа
  case setAccessCode
  /// Предложить установить FaceID
  case setFaceID
  /// Предложить включить уведомления
  case setNotifications
}
