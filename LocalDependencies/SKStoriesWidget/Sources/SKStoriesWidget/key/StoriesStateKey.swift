//
//  StoriesStateKey.swift
//
//
//

import SwiftUI

/// Emerging stories state for ``SKStoriesWidget``
@available(iOS 15.0, *)
struct StoriesStateKey: PreferenceKey {
  typealias Value = StoriesState
  
  static var defaultValue: StoriesState = .ready
  
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value = nextValue()
  }
}
