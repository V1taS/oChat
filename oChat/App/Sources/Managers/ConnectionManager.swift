//
//  ConnectionManager.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Combine
import SwiftUI
import ToxSwift

final class ConnectionManager: ObservableObject {

  @Published var connectionState: ConnectionStatus = .inProgress

  func handle(_ state: ToxConnectionState) {
    connectionState = (
      state == .none
    ) ? .offline : .online
  }
}

// MARK: - Preview

extension ConnectionManager {
  /// Заглушка с демо-данными, чтобы превью работало офлайн
  static var preview: ConnectionManager {
    let toxService = try! ToxService()
    let connectionManager = ConnectionManager()
    return connectionManager
  }
}
