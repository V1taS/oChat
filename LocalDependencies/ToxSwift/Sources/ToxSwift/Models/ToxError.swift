//
//  ToxError.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 7.05.2025.
//

import Foundation
import CTox
import CSodium

// MARK: – Ошибки высокого уровня для ToxService
public enum ToxError: Error, CustomStringConvertible {
  case creationFailed(TOX_ERR_NEW)
  case friendAddFailed(TOX_ERR_FRIEND_ADD)
  case friendRemoveFailed(TOX_ERR_FRIEND_DELETE)
  case messageSendFailed(TOX_ERR_FRIEND_SEND_MESSAGE)
  case fileSendFailed(TOX_ERR_FILE_SEND)
  case fileChunkFailed(TOX_ERR_FILE_SEND_CHUNK)
  case generic(String)
  case fileControlFailed(TOX_ERR_FILE_CONTROL)
  case fileSeekFailed(TOX_ERR_FILE_SEEK)
  case conferenceInviteFailed(TOX_ERR_CONFERENCE_INVITE)
  case conferenceJoinFailed(TOX_ERR_CONFERENCE_JOIN)
  case conferenceDeleteFailed(TOX_ERR_CONFERENCE_DELETE)

  public var description: String {
    switch self {
    case .creationFailed(let e):   return "tox_new() failed with \(e)"
    case .friendAddFailed(let e):  return "friend_add failed with \(e)"
    case .friendRemoveFailed(let e):return "friend_delete failed with \(e)"
    case .messageSendFailed(let e):return "send_message failed with \(e)"
    case .fileSendFailed(let e):   return "file_send failed with \(e)"
    case .fileChunkFailed(let e):  return "file_send_chunk failed with \(e)"
    case .generic(let msg):        return msg
    case .fileControlFailed(let msg): return "fileControlFailed with \(msg)"
    case .fileSeekFailed(let msg): return "fileSeekFailed with \(msg)"
    case .conferenceInviteFailed(let msg): return "conferenceInviteFailed with \(msg)"
    case .conferenceJoinFailed(let msg): return "conferenceJoinFailed with \(msg)"
    case .conferenceDeleteFailed(let msg): return "conferenceDeleteFailed with \(msg)"
    }
  }
}
