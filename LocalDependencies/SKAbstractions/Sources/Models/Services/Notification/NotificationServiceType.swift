//
//  NotificationServiceType.swift
//
//
//  Created by Vitalii Sosin on 27.02.2024.
//

import Foundation

public enum NotificationServiceType {
  /// Текст уведомления
  public var title: String {
    switch self {
    case let .positive(title):
      return title
    case let .neutral(title):
      return title
    case let .negative(title):
      return title
    }
  }
  
  /// Уведомление успеха
  case positive(title: String)
  /// Уведомление нейтральное
  case neutral(title: String)
  /// Уведомление ошибки
  case negative(title: String)
}
