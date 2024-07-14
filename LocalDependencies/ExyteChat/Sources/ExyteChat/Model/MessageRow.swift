//
//  Created by Sosin Vitalii on 08.07.2022.
//

import Foundation

/// Перечисление, определяющее позицию сообщения в группе
public enum PositionInGroup {
  /// Первое сообщение в группе
  case first
  
  /// Сообщение в середине группы
  case middle
  
  /// Последнее сообщение в группе
  case last
  
  /// Единственное сообщение в группе
  case single
}

struct MessageRow: Equatable {
  let message: Message
  let positionInGroup: PositionInGroup
  
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id && lhs.positionInGroup == rhs.positionInGroup && lhs.message.status == rhs.message.status
  }
}

extension MessageRow: Identifiable {
  public typealias ID = String
  public var id: String {
    return message.id
  }
}
