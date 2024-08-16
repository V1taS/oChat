//
//  File.swift
//
//
//  Created by Sosin Vitalii on 02.06.2023.
//

import SwiftUI

extension View {
  func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
