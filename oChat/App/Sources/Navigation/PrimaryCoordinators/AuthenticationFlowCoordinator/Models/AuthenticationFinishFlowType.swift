//
//  AuthenticationFinishFlowType.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 19.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation

public enum AuthenticationFinishFlowType {
  /// Успех
  case success
  
  /// Успех фейк
  case successFake
  
  /// Ошибка
  case failure
}
