//
//  ProgressBar.swift
//
//
//

import SwiftUI

/// Indicate time progress for ``StoriesView`` component
struct ProgressBar<Item: IStory>: View {
  /// Indicators height
  private let height: CGFloat = 2
  
  /// Space between indicators
  private let spacing: CGFloat = 5
  
  // MARK: - Config
  
  /// Set of data
  let stories: [Item]
  
  /// Current item from data set
  let current: Item
  
  /// Progress of showing current item
  let progress: CGFloat
  
  // MARK: - Life circle
  
  var body: some View {
    HStack(spacing: spacing) {
      ForEach(stories, id: \.self) { story in
        GeometryReader { proxy in
          let width = proxy.size.width
          itemTpl(story, width)
        }
      }
    }.frame(height: height)
  }
  
  // MARK: - private
  
  /// Progress slot view
  @ViewBuilder
  private func itemTpl(_ item: Item, _ width: CGFloat) -> some View {
    Color.primary.opacity(0.5)
      .overlay(progressTpl(item, width, current), alignment: .leading)
      .clipShape(Capsule())
  }
  
  /// Progress slot overlay view
  /// - Parameters:
  ///   - item: Story
  ///   - width: Available space
  ///   - current: Current story
  /// - Returns: View
  @ViewBuilder
  private func progressTpl(_ item: Item, _ width: CGFloat, _ current: Item) -> some View {
    if item.isBefore(current) { // has already passed
      Color.primary
    } else if item == current {
      Color.primary.frame(width: progress * width) // current progress
    } else {
      EmptyView()
    }
  }
}
