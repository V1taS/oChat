//
//  DetailPaymentScreenModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 05.05.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKUIKit

struct DetailPaymentScreenModel: Equatable {
  /// Дата активности, например: ``Январь 2024``
  let date: String
  /// Список активностей на эту дату
  let listActivity: [WidgetCryptoView.Model]
}
