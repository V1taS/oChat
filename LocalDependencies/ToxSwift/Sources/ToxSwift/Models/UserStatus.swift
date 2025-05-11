//
//  File.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 7.05.2025.
//

import Foundation
import CTox
import CSodium

// MARK: – Пользовательский статус друга

public enum UserStatus: UInt8, Sendable {
  case none  = 0        // TOX_USER_STATUS_NONE
  case away  = 1        // TOX_USER_STATUS_AWAY
  case busy  = 2        // TOX_USER_STATUS_BUSY
  
  /// Значение для C-API
  var cValue: TOX_USER_STATUS { TOX_USER_STATUS(rawValue: UInt32(self.rawValue)) }
}

// MARK: – Friend‑события

public enum FriendEvent: Sendable {
  case request(publicKey: Data, message: String)
  case nameChanged(friendID: UInt32, name: String)
  case statusMessageChanged(friendID: UInt32, message: String)
  case userStatusChanged(friendID: UInt32, status: UserStatus)
  case connectionStatusChanged(friendID: UInt32, state: ConnectionState)
  case typing(friendID: UInt32, isTyping: Bool)
  case readReceipt(friendID: UInt32, messageID: UInt32)
  case lossyPacket(friendID: UInt32, data: Data)
  case losslessPacket(friendID: UInt32, data: Data)
}
