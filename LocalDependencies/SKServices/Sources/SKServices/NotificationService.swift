//
//  NotificationService.swift
//
//
//  Created by Vitalii Sosin on 27.02.2024.
//

import SwiftUI
import SKNotifications
import SKStyle
import SKAbstractions

public final class NotificationService: INotificationService {
  public init() {}
  private let notifications = Notifications()
  
  public func showNotification(_ type: NotificationServiceType) {
    DispatchQueue.main.async { [weak self] in
      self?.showNotification(type, action: nil)
    }
  }
  
  public func showNotification(
    _ type: NotificationServiceType,
    action: (() -> Void)?
  ) {
    var backgroundColor: UIColor {
      switch type {
      case .positive:
        return SKStyleAsset.constantLime.color
      case .neutral:
        return SKStyleAsset.constantAzure.color
      case .negative:
        return SKStyleAsset.constantRuby.color
      }
    }
    
    notifications.showAlertWith(
      model: NotificationsModel(
        text: type.title,
        textColor: .black,
        style: .custom(
          backgroundColor: backgroundColor,
          glyph: nil,
          colorGlyph: nil
        ),
        timeout: Constants.timeout,
        glyph: false,
        throttleDelay: Constants.throttleDelay,
        action: action
      )
    )
  }
}

// MARK: - Constants

private enum Constants {
  static let timeout: Double = 2
  static let throttleDelay: Double = 0.5
  static let systemFontSize: CGFloat = 44
}
