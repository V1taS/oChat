//
//  Created by Sosin Vitalii on 02.10.2023.
//

import Foundation
import Combine
import UIKit

public final class KeyboardState: ObservableObject {
  @Published private(set) public var isShown: Bool = false
  
  private var subscriptions = Set<AnyCancellable>()
  
  // Singleton instance
  public static let shared = KeyboardState()
  
  // Private initializer to prevent creating additional instances
  private init() {
    subscribeKeyboardNotifications()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
}

private extension KeyboardState {
  func subscribeKeyboardNotifications() {
    Publishers.Merge(
      NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .map { _ in true },
      
      NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in false }
    )
    .receive(on: RunLoop.main)
    .assign(to: \.isShown, on: self)
    .store(in: &subscriptions)
  }
}
