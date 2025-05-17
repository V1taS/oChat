//
//  NotificationService.swift
//  oChat
//
//  Created by Vitalii Sosin on 17.05.2025.
//  Copyright © 2025 SosinVitalii.com. All rights reserved.
//

import UIKit
import SKNotifications

public final class NotificationService {
  public static let shared = NotificationService()
  private init() {}
  private let notifications = Notifications()

  public func showNegativeAlertWith(title: String, active: (() -> Void)? = nil) {
    DispatchQueue.main.async { [weak self] in
      let appearance = Appearance()
      self?.notifications.showAlertWith(
        model: NotificationsModel(
          text: title,
          textColor: .black,
          style: .negative(colorGlyph: .black),
          timeout: appearance.timeout,
          glyph: false,
          throttleDelay: appearance.throttleDelay,
          action: active
        )
      )
    }
  }

  public func showPositiveAlertWith(title: String, active: (() -> Void)? = nil) {
    DispatchQueue.main.async { [weak self] in
      let appearance = Appearance()
      self?.notifications.showAlertWith(
        model: NotificationsModel(
          text: title,
          textColor: .black,
          style: .positive(colorGlyph: .black),
          timeout: appearance.timeout,
          glyph: false,
          throttleDelay: appearance.throttleDelay,
          action: active
        )
      )
    }
  }
}

// MARK: - Appearance

private extension NotificationService {
  struct Appearance {
    let timeout: Double = 2
    let throttleDelay: Double = 0.5
    let systemFontSize: CGFloat = 44
  }
}
