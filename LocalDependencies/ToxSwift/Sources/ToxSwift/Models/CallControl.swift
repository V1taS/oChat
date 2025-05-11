//
//  CallControl.swift
//  ToxSwift
//
//  Created by Vitalii Sosin on 07.05.2025.
//

import Foundation
import CTox
import CSodium

// MARK: – Управление вызовом (Swift‑friendly)

/// Действие, которое мы хотим выполнить с текущим звонком.
public enum CallControl: Sendable {
  /// Возобновить приостановленный звонок.
  case resume
  /// Поставить звонок на паузу.
  case pause
  /// Отклонить входящий / отменить активный звонок.
  case cancel
  /// Попросить друга перестать отправлять аудио.
  case muteAudio
  /// Попросить снова присылать аудио.
  case unmuteAudio
  /// Попросить друга перестать отправлять видео.
  case hideVideo
  /// Попросить снова присылать видео.
  case showVideo

  // MARK: – Маппинг на/из C‑enumeration

  /// Значение, которое нужно передать в `toxav_call_control` (C‑API).
  public var cValue: Toxav_Call_Control {
    switch self {
    case .resume: return TOXAV_CALL_CONTROL_RESUME
    case .pause: return TOXAV_CALL_CONTROL_PAUSE
    case .cancel: return TOXAV_CALL_CONTROL_CANCEL
    case .muteAudio: return TOXAV_CALL_CONTROL_MUTE_AUDIO
    case .unmuteAudio: return TOXAV_CALL_CONTROL_UNMUTE_AUDIO
    case .hideVideo: return TOXAV_CALL_CONTROL_HIDE_VIDEO
    case .showVideo: return TOXAV_CALL_CONTROL_SHOW_VIDEO
    }
  }

  /// Инициализатор из `Toxav_Call_Control` (например, в коллбекe).
  public init?(cValue: Toxav_Call_Control) {
    switch cValue {
    case TOXAV_CALL_CONTROL_RESUME: self = .resume
    case TOXAV_CALL_CONTROL_PAUSE: self = .pause
    case TOXAV_CALL_CONTROL_CANCEL: self = .cancel
    case TOXAV_CALL_CONTROL_MUTE_AUDIO: self = .muteAudio
    case TOXAV_CALL_CONTROL_UNMUTE_AUDIO: self = .unmuteAudio
    case TOXAV_CALL_CONTROL_HIDE_VIDEO: self = .hideVideo
    case TOXAV_CALL_CONTROL_SHOW_VIDEO: self = .showVideo
    default: return nil
    }
  }
}
