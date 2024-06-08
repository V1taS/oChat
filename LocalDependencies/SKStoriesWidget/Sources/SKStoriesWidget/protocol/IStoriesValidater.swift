//
//  IStoriesValidater.swift
//
//
//

import Foundation

/// Interface to validate input stories data for ``SKStoriesWidget``
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
public protocol IStoriesValidater {
  /// Check stories data
  /// - Parameter stories: Set of stories data
  /// - Returns: Errors
  static func validate<T: IStory>(_ stories: [T]) -> [StoriesError]
}
