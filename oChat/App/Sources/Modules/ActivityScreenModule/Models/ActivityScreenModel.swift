//
//  ActivityScreenModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKUIKit

struct ActivityScreenModel: Equatable {
  /// Дата активности, например: ``Январь 2024``
  let date: String
  /// Список активностей на эту дату
  let listActivity: [WidgetCryptoView.Model]
}
