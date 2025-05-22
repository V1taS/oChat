//
//  CallManager.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Combine
import SwiftUI
import ToxSwift

/// Менеджер аудио/видео звонков.
final class CallManager: ObservableObject {
  @Published var activeCalls: [UInt32: CallState] = [:]
  private let toxService: ToxServiceProtocol

  init(toxService: ToxServiceProtocol) {
    self.toxService = toxService
  }

  func handleCallEvent(_ event: CallEvent) {
    if case let .call(fid, audio, video) = event {
      activeCalls[fid] = CallState(audioEnabled: audio, videoEnabled: video)
    }
  }
}

// MARK: - Preview

extension CallManager {
  /// Заглушка с демо-данными, чтобы превью работало офлайн
  static var preview: CallManager {
    let toxService = try! ToxService()
    let callManager = CallManager(
      toxService: toxService
    )
    return callManager
  }
}
