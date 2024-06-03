//
//  DetailPaymentFinishFlowType.swift
//  oChat
//
//  Created by Vitalii Sosin on 05.05.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKUIKit

// MARK: - DetailPaymentFinishFlowType

public enum DetailPaymentFinishFlowType {
  /// Успех
  case success
  
  /// Ошибка
  case failure
  
  /// Просто закрыли флоу
  case close
}
