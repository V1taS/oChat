//
//  MessengerNewMessengeScreenInteractor.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol MessengerNewMessengeScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol MessengerNewMessengeScreenInteractorInput {
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
}

/// Интерактор
final class MessengerNewMessengeScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MessengerNewMessengeScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let notificationService: INotificationService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(services: IApplicationServices) {
    notificationService = services.userInterfaceAndExperienceService.notificationService
  }
}

// MARK: - MessengerNewMessengeScreenInteractorInput

extension MessengerNewMessengeScreenInteractor: MessengerNewMessengeScreenInteractorInput {
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    notificationService.showNotification(type)
  }
}

// MARK: - Private

private extension MessengerNewMessengeScreenInteractor {}

// MARK: - Constants

private enum Constants {}
