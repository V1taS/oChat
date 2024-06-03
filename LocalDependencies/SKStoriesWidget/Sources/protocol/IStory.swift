//
//  IStory.swift
//
//
//

import SwiftUI

/// Interface defining story view
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
public protocol IStory: Hashable, CaseIterable {
  associatedtype ViewTpl: View
  
  // MARK: - Config
  
  /// Story duration
  var duration: TimeInterval { get }
  
  // MARK: - API
  
  /// Define view template for every story
  func builder(progress: Binding<CGFloat>) -> ViewTpl
  
  /// Check the position relatively the currently showing story
  func isBefore(_ current: Self) -> Bool
  
  /// Get next element
  var next: Self { get }
  
  /// Get previous element
  var previous: Self { get }
}

public extension IStory {
  /// Check the position relatively the currently showing story
  /// - Parameter current: Current story
  /// - Returns: true - `self`  is before current
  func isBefore(_ current: Self) -> Bool {
    let all = Self.allCases
    
    guard let itemIdx = all.firstIndex(of: current) else {
      return false
    }
    
    guard let idx = all.firstIndex(of: self) else {
      return false
    }
    
    return idx < itemIdx
  }
  
  /// Get next element
  /// - Returns: previous element or current if previous does not exist
  var next: Self {
    let all = Self.allCases
    let startIndex = all.startIndex
    let endIndex = all.endIndex
    
    guard let idx = all.firstIndex(of: self) else {
      return self
    }
    
    let next = all.index(idx, offsetBy: 1)
    
    return next == endIndex ? all[startIndex] : all[next]
  }
  
  /// Get previous element
  /// - Returns: previous element or current if previous does not exist
  var previous: Self {
    let all = Self.allCases
    let startIndex = all.startIndex
    let endIndex = all.index(all.endIndex, offsetBy: -1)
    
    guard let idx = all.firstIndex(of: self) else {
      return self
    }
    
    let previous = all.index(idx, offsetBy: -1)
    
    return previous < startIndex ? all[endIndex] : all[previous]
  }
}
