//
//  Created by Sosin Vitalii on 02.06.2023.
//

import Foundation

public typealias MediaPickerCompletionClosure = ([Media]) -> Void
public typealias MediaPickerOrientationHandler = (ShouldLock) -> Void
public typealias SimpleClosure = ()->()

public enum ShouldLock {
  case lock, unlock
}
