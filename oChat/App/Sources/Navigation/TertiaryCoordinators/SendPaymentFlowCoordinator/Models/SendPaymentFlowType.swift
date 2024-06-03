//
//  SendPaymentFlowType.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKUIKit
import SKAbstractions

// MARK: - SendPaymentFlowType

public enum SendPaymentFlowType {
  /// Открыть экран с главного. Вверхний таббар будет кликабелен и можно выбрать  Токен
  case openFromMainScreen
  /// Открыть экран из деталей. Вверхний таббар будет НЕ кликабелен и НЕЛЬЗЯ выбрать  Токен
  case openFromDetailScreen(_ model: TokenModel)
}
