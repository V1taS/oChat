//
//  CreateOrRestoreWalletSheetModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI

struct CreateOrRestoreWalletSheetModel {
  /// Иконка на виджете
  let image: Image
  /// Заголовок виджета
  let title: String
  /// Описание виджета
  let description: String
  /// Было нажатие на виджет
  let action: (() -> Void)?
}

// MARK: - Equatable

extension CreateOrRestoreWalletSheetModel: Equatable {
  static func == (
    lhs: CreateOrRestoreWalletSheetModel,
    rhs: CreateOrRestoreWalletSheetModel
  ) -> Bool {
    lhs.image == rhs.image &&
    lhs.title == rhs.title &&
    lhs.description == rhs.description
  }
}

// MARK: - Hashable

extension CreateOrRestoreWalletSheetModel: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(description)
  }
}
