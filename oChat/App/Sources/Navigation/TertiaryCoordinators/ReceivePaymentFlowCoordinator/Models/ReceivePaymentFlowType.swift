//
//  ReceivePaymentFlowType.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKUIKit
import SKAbstractions

// MARK: - ReceivePaymentFlowType

public enum ReceivePaymentFlowType {
  /// Первоночальный экран выбора сети и монеты
  case initial
  /// Экран на котором можно скопировать реквизиты
  case shareRequisites(_ model: TokenModel)
}
