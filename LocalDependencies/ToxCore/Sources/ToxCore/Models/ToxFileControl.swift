//
//  ToxFileControl.swift
//
//
//  Created by Vitalii Sosin on 10.06.2024.
//

import Foundation
import ToxCoreCpp

// MARK: - ToxFileControl Enum

public enum ToxFileControl {
  case pause
  case resume
  case cancel
  
  public func toCFileControl() -> TOX_FILE_CONTROL {
    switch self {
    case .pause:
      return TOX_FILE_CONTROL_PAUSE
    case .resume:
      return TOX_FILE_CONTROL_RESUME
    case .cancel:
      return TOX_FILE_CONTROL_CANCEL
    }
  }
  
  public static func fromCFileControl(_ cFileControl: TOX_FILE_CONTROL) -> ToxFileControl? {
    switch cFileControl {
    case TOX_FILE_CONTROL_PAUSE:
      return .pause
    case TOX_FILE_CONTROL_RESUME:
      return .resume
    case TOX_FILE_CONTROL_CANCEL:
      return .cancel
    default:
      return nil
    }
  }
}
