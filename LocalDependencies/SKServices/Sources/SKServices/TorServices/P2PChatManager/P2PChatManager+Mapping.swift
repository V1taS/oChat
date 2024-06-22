//
//  P2PChatManager+Mapping.swift
//  SKServices
//
//  Created by Vitalii Sosin on 22.06.2024.
//

import SwiftUI
import SKAbstractions
import ToxCore


// MARK: - Mapping ToxSendMessageType

extension ToxSendMessageType {
  func mapTo() -> ToxMessageType {
    switch self {
    case .normal:
      return .normal
    case .action:
      return .action
    }
  }
}

// MARK: - Mapping ConnectionToxStatus

extension ConnectionStatus {
  func mapTo() -> ConnectionToxStatus {
    switch self {
    case .none:
      return .none
    case .tcp:
      return .tcp
    case .udp:
      return .udp
    }
  }
}

// MARK: - Mapping UserStatus

extension UserStatus {
  func mapTo() -> ContactModel.Status {
    switch self {
    case .online:
      return .online
    case .away:
      return .offline
    case .busy:
      return .offline
    }
  }
}
