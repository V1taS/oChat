//
//  Strategy.swift
//
//
//

import Foundation

/// Strategy for showing stories
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
public enum Strategy {
  /// Repeat stories
  case circle
  
  /// Show just once
  case once
}
