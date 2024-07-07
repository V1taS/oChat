//
//  MessengerDialogScreenInteractor.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol MessengerDialogScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol MessengerDialogScreenInteractorInput {
  /// Получаем обновленный контакт
  func getNewContactModels(_ contactModel: ContactModel, completion: ((ContactModel) -> Void)?)
  
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
  
  /// Копирует текст в буфер обмена.
  /// - Parameters:
  ///   - text: Текст для копирования.
  func copyToClipboard(text: String)
}

/// Интерактор
final class MessengerDialogScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: MessengerDialogScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let modelHandlerService: IMessengerModelHandlerService
  private let systemService: ISystemService
  private let cryptoService: ICryptoService
  private let notificationService: INotificationService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(services: IApplicationServices) {
    modelHandlerService = services.messengerService.modelHandlerService
    systemService = services.userInterfaceAndExperienceService.systemService
    cryptoService = services.accessAndSecurityManagementService.cryptoService
    notificationService = services.userInterfaceAndExperienceService.notificationService
  }
}

// MARK: - MessengerDialogScreenInteractorInput

extension MessengerDialogScreenInteractor: MessengerDialogScreenInteractorInput {
  func copyToClipboard(text: String) {
    systemService.copyToClipboard(text: text)
  }
  
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    DispatchQueue.main.async { [weak self] in
      self?.notificationService.showNotification(type)
    }
  }
  
  func getNewContactModels(_ contactModel: ContactModel, completion: ((ContactModel) -> Void)?) {
    modelHandlerService.getContactModels { contactModels in
      DispatchQueue.main.async {
        if let contactIndex = contactModels.firstIndex(where: { $0.toxAddress == contactModel.toxAddress }) {
          completion?(contactModels[contactIndex])
        } else {
          completion?(contactModel)
        }
      }
    }
  }
}

// MARK: - Private

private extension MessengerDialogScreenInteractor {}

// MARK: - Constants

private enum Constants {}
