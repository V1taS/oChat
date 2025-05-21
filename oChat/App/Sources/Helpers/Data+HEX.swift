//
//  Data+HEX.swift
//  oChat
//
//  Created by Vitalii Sosin on 20.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

extension Data {
  var hex: String { map { String(format: "%02x", $0) }.joined() }
}
