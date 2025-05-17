//
//  ChatRules.swift
//  oChat
//
//  Created by Vitalii Sosin on 15.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import Foundation

// MARK: – Период автo-удаления сообщений

/// Возможные интервалы для автоматического удаления сообщений.
public enum AutoDeletionPeriod: Codable, CaseIterable {
  /// Удалять через 1 минуту.
  case oneMinute
  /// Удалять через 15 минут.
  case fifteenMinutes
  /// Удалять через 1 день.
  case oneDay
  /// Удалять через 1 месяц.
  case oneMonth
  /// Не удалять автоматически.
  case never

  /// Соответствующий интервал в секундах (0 — «никогда»).
  public var seconds: TimeInterval {
    switch self {
    case .oneMinute: return 60
    case .fifteenMinutes: return 15 * 60
    case .oneDay: return 24 * 60 * 60
    case .oneMonth: return 30 * 24 * 60 * 60
    case .never: return 0
    }
  }

  /// Человекочитаемые подписи для UI
  var title: String {
    switch self {
    case .oneMinute: return "1 мин"
    case .fifteenMinutes: return "15 мин"
    case .oneDay: return "1 день"
    case .oneMonth: return "1 мес"
    case .never: return "Никогда"
    }
  }
}

// MARK: – Правила приватности чата

/// Правила, задающие разрешённые действия и уровень приватности для конкретного чата.
public struct ChatRules: Codable, Equatable {

  /// Разрешено ли сохранять медиа-файлы (фото, видео, документы) на устройство.
  public var isMediaSavingAllowed: Bool

  /// Разрешено ли копировать текст сообщений из переписки.
  public var isTextCopyAllowed: Bool

  /// Период автоматического удаления сообщений.
  public var autoDeletion: AutoDeletionPeriod

  /// Скрывать ли реальный голос при звонках и аудио-сообщениях (voice masking).
  public var isVoiceMaskingEnabled: Bool

  /// Отображать ли индикатор набора текста («…»).
  public var isTypingIndicatorEnabled: Bool

  /// Разрешены ли аудио-звонки от контакта.
  public var isAudioCallAllowed: Bool

  /// Разрешены ли видео-звонки от контакта.
  public var isVideoCallAllowed: Bool

  /// Разрешены ли скриншоты экрана в этом чате.
  public var areScreenshotsAllowed: Bool

  /// Отправлять ли подтверждения о прочтении сообщений (read receipts).
  public var areReadReceiptsEnabled: Bool

  /// Базовый инициализатор со значениями по умолчанию.
  public init(
    isMediaSavingAllowed: Bool = false,
    isTextCopyAllowed: Bool = false,
    autoDeletion: AutoDeletionPeriod = .oneMonth,
    isVoiceMaskingEnabled: Bool = false,
    isTypingIndicatorEnabled: Bool = true,
    isAudioCallAllowed: Bool = true,
    isVideoCallAllowed: Bool = true,
    areScreenshotsAllowed: Bool = false,
    areReadReceiptsEnabled: Bool = true,
  ) {
    self.isMediaSavingAllowed = isMediaSavingAllowed
    self.isTextCopyAllowed = isTextCopyAllowed
    self.autoDeletion = autoDeletion
    self.isVoiceMaskingEnabled = isVoiceMaskingEnabled
    self.isTypingIndicatorEnabled = isTypingIndicatorEnabled
    self.isAudioCallAllowed = isAudioCallAllowed
    self.isVideoCallAllowed = isVideoCallAllowed
    self.areScreenshotsAllowed = areScreenshotsAllowed
    self.areReadReceiptsEnabled = areReadReceiptsEnabled
  }
}
