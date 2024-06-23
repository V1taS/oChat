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
  
  /// Расшифровывает данные, используя приватный ключ.
  /// - Parameters:
  ///   - encryptedData: Зашифрованные данные.
  /// - Returns: Расшифрованные данные.
  /// - Throws: Ошибка расшифровки данных.
  func decrypt(_ encryptedData: String?) -> String?
  
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
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    notificationService.showNotification(type)
  }
  
  func decrypt(_ encryptedData: String?) -> String? {
    cryptoService.decrypt(encryptedData, privateKey: systemService.getDeviceIdentifier())
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
  
  func getCostOfSendingMessage() -> Decimal? {
    nil
  }
}

// MARK: - Private

private extension MessengerDialogScreenInteractor {}

// MARK: - Constants

private enum Constants {}
