//
//  ReceivePaymentFinishFlowType.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKUIKit

// MARK: - ReceivePaymentFinishFlowType

public enum ReceivePaymentFinishFlowType {
  /// Успех
  case success
  
  /// Ошибка
  case failure
  
  /// Просто закрыли флоу
  case close
}
