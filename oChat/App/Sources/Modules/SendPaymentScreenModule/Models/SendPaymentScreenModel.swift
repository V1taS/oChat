//
//  SendPaymentScreenModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 23.04.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import Foundation
import SKAbstractions

public struct SendPaymentScreenModel: Equatable {
  /// Тип экрана
  let screenType: SendPaymentScreenType
  /// Модель данных
  let tokenModel: TokenModel
}
