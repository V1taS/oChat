//
//  CallState.swift
//  oChat
//
//  Created by Vitalii Sosin on 14.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

enum CallPhase: Sendable {
  case outgoingRinging   // исходящий, ждём ответа
  case incomingRinging   // входящий, ждём решения
  case active            // обе стороны в линии
}

struct CallState: Identifiable, Equatable, Sendable {
  let id: UInt32                 // friendID
  var phase: CallPhase           // ← единственный флаг “где мы сейчас”

  // текущее состояние потоков
  var audioEnabled: Bool
  var videoEnabled: Bool

  // локальные переключатели
  var isOnHold:   Bool = false
  var isSpeakerOn: Bool = false
}
