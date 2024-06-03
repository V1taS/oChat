//
//  StoriesStateKey.swift
//
//
//

import SwiftUI

/// Emerging stories state for ``SKStoriesWidget``
struct StoriesStateKey: PreferenceKey {
  typealias Value = StoriesState
  
  static var defaultValue: StoriesState = .ready
  
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value = nextValue()
  }
}
