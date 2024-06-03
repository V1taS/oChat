//
//  ListTokensScreenType.swift
//  oChat
//
//  Created by Vitalii Sosin on 25.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKAbstractions

// MARK: - ListTokensScreenType

public enum ListTokensScreenType {
  /// Просто список токенов какой то сети
  case tokenSelectioList(tokenModel: TokenModel)
  /// Список всех токенов для добавления на главный экран
  case addTokenOnMainScreen(tokenModels: [TokenModel])
}
