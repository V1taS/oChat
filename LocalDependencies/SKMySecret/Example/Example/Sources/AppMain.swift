//
//  AppDelegate.swift
//  RandomNetworkExample
//
//  Created by Vitalii Sosin on 16.02.2024.
//

import SwiftUI
import SKMySecret

@main
struct AppMain: App {
  
  var body: some Scene {
    WindowGroup {
      ImageTextProcessorExample()
        .onTapGesture {
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
  }
}
