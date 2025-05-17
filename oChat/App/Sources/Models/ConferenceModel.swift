//
//  ConferenceModel.swift
//  oChat
//
//  Created by Vitalii Sosin on 14.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation
import ToxSwift

/// Модель конференции
struct ConferenceModel: Identifiable, Codable, Equatable {
  let id: UInt32
  var title: String
  let type: ConferenceType
}

extension ConferenceType: Codable {}
