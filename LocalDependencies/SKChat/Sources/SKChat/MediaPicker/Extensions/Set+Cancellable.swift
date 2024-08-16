//
//  Created by Sosin Vitalii on 02.06.2023.
//

import Foundation
import Combine

extension Set where Element == AnyCancellable {
  mutating func cancelAll() {
    self = Set<AnyCancellable>()
  }
}
