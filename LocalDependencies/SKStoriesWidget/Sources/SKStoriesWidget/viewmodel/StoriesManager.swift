//
//  StoriesManager.swift
//
//
//

import Combine
import SwiftUI

/// Managing logic for ``SKStoriesWidget`` component
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
public final class StoriesManager<Item: IStory>: IStoriesManager {
  /// Time progress demonstrating the current story
  @Published public var progress: CGFloat = StateManager.startProgress
  
  /// Current stories state
  ///  Life circle: Start - ... Begin - (Suspend) - (Resume) - End ... - Finish
  @Published public private(set) var state: StoriesState = .ready
  
  /// Check is suspended
  public var suspended: Bool { if case .suspend = state { return true } else { return false } }
  
  /// State manager
  private let manager = StateManager()
  
  /// Subscriptions
  private var sub: AnyCancellable?
  
  @Published public var tapTime: Bool = false
  
  // MARK: - Config
  
  /// Current story
  @Published public private(set) var current: Item
  
  /// Set of stories
  @Published public private(set) var stories: [Item]
  
  /// One of the strategy defined in enum ``Strategy``
  public let strategy: Strategy
  
  /// Delay before start counting stories time
  public let leeway: DispatchTimeInterval
  
  // MARK: - Life circle
  
  /// Delay before start showing stories
  public init(
    stories: [Item],
    current: Item? = nil,
    strategy: Strategy = .circle,
    leeway: DispatchTimeInterval = .seconds(0)
  ) {
    self.stories = stories
    self.current = current ?? stories.first!
    self.strategy = strategy
    self.leeway = leeway
    
    sub = manager
      .publisher
      .sink { [weak self] in
        self?.onStateChanged($0)
      }
  }
  
  // MARK: - API
  
  /// Pause showing stories
  public func suspend() {
    if suspended { return }
    
    manager.suspend()
    
    tapTime = true
    Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
      self?.tapTime = false
    }
  }
  
  /// Rsume showing stories
  public func resume() {
    manager.resume()
  }
  
  /// Start showing stories
  public func start() {
    manager.start(current.duration, leeway: leeway)
  }
  
  /// Finish showing stories
  public func finish() {
    manager.finish()
  }
  
  /// Next story
  public func next() {
    current = current.next
    if validateOnce(current) { return finish() }
    manager.begin(current.duration)
  }
  
  /// Previous story
  public func previouse() {
    current = current.previous
    manager.begin(current.duration)
  }
  
  // MARK: - Private
  
  private func validateOnce(_ next: Item) -> Bool {
    strategy == .once && next == stories.first
  }
  
  /// Process state change
  /// - Parameter state: Stories showcase state
  private func onStateChanged(_ state: StoriesState) {
    /// Need this to overcome SwiftUI view update specifics
    if state != .begin { self.state = state }
    
    switch state {
    case .begin: initAnimation()
    case .end: next()
    case let .suspend(progress): return suspendAnimation(progress)
    case let .resume(progress): resumeAnimation(progress)
    default: return
    }
    /// Need this to overcome SwiftUI view update specifics
    if state == .begin { self.state = state }
  }
  
  /// Typical time slot for a story
  private func initAnimation() {
    progress = StateManager.startProgress
    runAnimation(1, current.duration)
  }
  
  private func suspendAnimation(_ progress: CGFloat) {
    runAnimation(progress, 0)
  }
  
  private func resumeAnimation(_ progress: CGFloat) {
    let duration = (1 - progress) * current.duration
    runAnimation(1, duration)
  }
  
  /// Costumed animation for progress
  /// - Parameters:
  ///   - progress: Endpoint progress
  ///   - duration: Time
  private func runAnimation(_ progress: CGFloat, _ duration: Double) {
    withAnimation(.linear(duration: duration)) {
      self.progress = progress
    }
  }
}
