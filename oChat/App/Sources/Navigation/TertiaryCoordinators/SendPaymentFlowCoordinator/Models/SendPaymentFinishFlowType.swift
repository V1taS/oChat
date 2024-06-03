//
//  SendPaymentFinishFlowType.swift
//  oChat
//
//  Created by Vitalii Sosin on 26.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKUIKit

// MARK: - SendPaymentFinishFlowType

public enum SendPaymentFinishFlowType {
  /// Успех
  case success
  
  /// Ошибка
  case failure
  
  /// Просто закрыли флоу
  case close
}
