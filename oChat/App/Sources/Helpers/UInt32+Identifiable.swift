//
//  UInt32+Identifiable.swift
//  oChat
//
//  Created by Vitalii Sosin on 24.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

extension UInt32: @retroactive Identifiable {
  public var id: UInt32 { self }
}
