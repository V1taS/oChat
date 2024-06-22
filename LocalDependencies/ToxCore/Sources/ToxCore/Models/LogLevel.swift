//
//  LogLevel.swift
//  ToxCore
//
//  Created by Vitalii Sosin on 16.06.2024.
//

import Foundation
import ToxCoreCpp

/// Уровни логирования.
public enum LogLevel: Int {
  case trace
  case debug
  case info
  case warning
  case error
  
  /// Конвертация из `Tox_Log_Level` в `LogLevel`.
  static func from(_ toxLogLevel: Tox_Log_Level) -> LogLevel {
    switch toxLogLevel {
    case TOX_LOG_LEVEL_TRACE:
      return .trace
    case TOX_LOG_LEVEL_DEBUG:
      return .debug
    case TOX_LOG_LEVEL_INFO:
      return .info
    case TOX_LOG_LEVEL_WARNING:
      return .warning
    case TOX_LOG_LEVEL_ERROR:
      return .error
    default:
      return .error
    }
  }
  
  /// Конвертация из `LogLevel` в `Tox_Log_Level`.
  func toToxLogLevel() -> Tox_Log_Level {
    switch self {
    case .trace:
      return TOX_LOG_LEVEL_TRACE
    case .debug:
      return TOX_LOG_LEVEL_DEBUG
    case .info:
      return TOX_LOG_LEVEL_INFO
    case .warning:
      return TOX_LOG_LEVEL_WARNING
    case .error:
      return TOX_LOG_LEVEL_ERROR
    }
  }
}
