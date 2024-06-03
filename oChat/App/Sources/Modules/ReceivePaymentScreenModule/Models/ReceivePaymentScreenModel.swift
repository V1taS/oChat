//
//  ReceivePaymentScreenModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 03.05.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKUIKit

struct ReceivePaymentScreenModel: Equatable, Identifiable, Hashable {
  /// Уникальный ID
  var id: String
  /// Заголовок
  let title: String
  /// Виджет
  let widget: WidgetCryptoView.Model
}
