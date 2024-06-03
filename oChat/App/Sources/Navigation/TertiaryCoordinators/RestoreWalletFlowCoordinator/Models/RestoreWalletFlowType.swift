//
//  RestoreWalletFlowType.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKUIKit

// MARK: - RestoreWalletFlowType

public enum RestoreWalletFlowType: Equatable {
  /// Стандартный кошелек с сид фразой
  case seedPhrase
  /// Высокотехнологичный кошелек с Image ID
  case highTechImageID
  /// Кошелек для отслеживания
  case trackingWallet
}
