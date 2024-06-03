//
//  CreatePhraseWalletScreenState.swift
//  oChat
//
//  Created by Vitalii Sosin on 18.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKUIKit

// MARK: - CurrentStateScreen

enum CreatePhraseWalletScreenState: Equatable {
  /// Кошелек создается
  case generatingWallet
  /// Кошелек создан
  case walletCreated
}
