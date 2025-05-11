//
//  ConferenceType.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 7.05.2025.
//

import Foundation
import CTox
import CSodium

// MARK: - Конференции

public enum ConferenceType: UInt32, Sendable {
  case audioVideo = 0
  case text       = 1
}

public enum ConferenceEvent: Sendable {
  case invited(friendID: UInt32, cookie: Data)
  case connected(conferenceID: UInt32)
  case message(conferenceID: UInt32,
               peerID: UInt32,
               kind: MessageKind,
               text: String)
  case titleChanged(conferenceID: UInt32, title: String)
  case peerNameChanged(conferenceID: UInt32,
                       peerID: UInt32,
                       name: String)
  case peerListChanged(conferenceID: UInt32)
}
