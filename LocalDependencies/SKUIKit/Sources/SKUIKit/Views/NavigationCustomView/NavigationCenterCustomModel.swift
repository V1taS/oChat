//
//  NavigationCenterCustomModel.swift
//  
//
//  Created by Vitalii Sosin on 27.01.2024.
//

import SwiftUI

// MARK: - NavigationCenterCustomModel

public enum NavigationCenterCustomModel: Equatable {
  case widgetCryptoView(text: String, image: Image? = nil, isSelectable: Bool = true)
  case none
}
