//
//  StoriesError.swift
//
//
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
public struct StoriesError: IStoriesError, @unchecked Sendable {
  public let description: LocalizedStringKey
  
  public init(description: LocalizedStringKey) {
    self.description = description
  }
}

public extension StoriesError {
  func hash(into hasher: inout Hasher) {
    hasher.combine("\(description)")
  }
}
