//
//  CreateWalletFlowType.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKUIKit

// MARK: - CreateWalletFlowType

public enum CreateWalletFlowType {
  /// Стандартный кошелек
  case seedPhrase12
  /// Нерушимый кошелек
  case seedPhrase24
  /// Высокотехнологичный кошелек с Image ID
  case highTechImageID
}
