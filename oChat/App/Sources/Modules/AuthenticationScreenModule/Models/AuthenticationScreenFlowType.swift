//
//  AuthenticationScreenFlowType.swift
//  oChat
//
//  Created by Vitalii Sosin on 06.08.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation

// MARK: - AuthenticationScreenFlowType

public enum AuthenticationScreenFlowType: Equatable {
  /// Только основное флоу
  case mainFlow
  
  /// Только фейковое флоу
  case fakeFlow
  
  /// Любое флоу
  case all
}
