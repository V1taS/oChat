//
//  SuggestScreenAbstractions.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SwiftUI

/// События, которые отправляем из `SuggestScreenModule` в `Coordinator`
public protocol SuggestScreenModuleOutput: AnyObject {
  
  /// Вызывается при нажатии на кнопку пропуска экрана предложения кода доступа.
  /// - Parameter isNotifications: Указывает, включены ли уведомления.
  func skipSuggestAccessCodeScreenButtonTapped(_ isNotifications: Bool)
  
  /// Вызывается при нажатии на кнопку пропуска экрана предложения уведомлений.
  func skipSuggestNotificationsScreenButtonTapped()
  
  /// Вызывается при нажатии на кнопку подтверждения экрана предложения кода доступа.
  func suggestAccessCodeScreenConfirmButtonTapped()
  
  /// Вызывается при нажатии на кнопку подтверждения экрана предложения FaceID.
  /// - Parameter isEnabledNotifications: Указывает, включены ли уведомления.
  func suggestFaceIDScreenConfirmButtonTapped(_ isEnabledNotifications: Bool)
  
  /// Вызывается при нажатии на кнопку подтверждения экрана предложения уведомлений.
  func suggestNotificationScreenConfirmButtonTapped()
}

/// События которые отправляем из `Coordinator` в `SuggestScreenModule`
public protocol SuggestScreenModuleInput {
  
  /// События которые отправляем из `SuggestScreenModule` в `Coordinator`
  var moduleOutput: SuggestScreenModuleOutput? { get set }
}

/// Готовый модуль `SuggestScreenModule`
public typealias SuggestScreenModule = (viewController: UIViewController, input: SuggestScreenModuleInput)
