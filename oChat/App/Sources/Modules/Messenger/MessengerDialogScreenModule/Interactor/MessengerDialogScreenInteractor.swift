//
//  MessengerDialogScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol MessengerDialogScreenInteractorOutput: AnyObject {
  /// Сообщение было отправлено успешно
  func didSendMessageSuccess()
  /// Сообщение не отправлено
  func didSendMessageFailure()
}

/// События которые отправляем от Presenter к Interactor
protocol MessengerDialogScreenInteractorInput {
  /// Отправить сообщение в блокчайн
  func sendMessage(_ text: String)
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
}

/// Интерактор
final class MessengerDialogScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MessengerDialogScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let notificationService: INotificationService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(services: IApplicationServices) {
    notificationService = services.userInterfaceAndExperienceService.notificationService
  }
}

// MARK: - MessengerDialogScreenInteractorInput

extension MessengerDialogScreenInteractor: MessengerDialogScreenInteractorInput {
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    notificationService.showNotification(type)
  }
  
  func sendMessage(_ text: String) {
#warning("TODO: - Когда подключим библиотеку, то сможем обратиться к сервису и отправить сообщение")
    if true {
      output?.didSendMessageSuccess()
    } else {
      output?.didSendMessageFailure()
    }
  }
}

// MARK: - Private

private extension MessengerDialogScreenInteractor {}

// MARK: - Constants

private enum Constants {}
