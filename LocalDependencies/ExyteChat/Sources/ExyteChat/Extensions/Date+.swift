//
//  Created Sosin Vitalii on 04.07.2022.
//

import Foundation

extension Date {
  func startOfDay() -> Date {
    Calendar.current.startOfDay(for: self)
  }
  
  func isSameDay(_ date: Date?) -> Bool {
    guard let date else {
      return false
    }
    return Calendar.current.isDate(self, inSameDayAs: date)
  }
}
