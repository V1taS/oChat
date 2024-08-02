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
  func getNewContactModels(_ contactModel: ContactModel) async -> ContactModel
  
  /// Показать уведомление
  /// - Parameters:
  ///   - type: Тип уведомления
  func showNotification(_ type: NotificationServiceType)
  
  /// Копирует текст в буфер обмена.
  /// - Parameters:
  ///   - text: Текст для копирования.
  func copyToClipboard(text: String)
  
  /// Сохраняет объект по указанному временному URL и возвращает новый URL сохраненного объекта.
  /// - Parameter tempURL: Временный URL, по которому сохраняется объект.
  /// - Returns: Новый URL сохраненного объекта или nil в случае ошибки.
  func saveObjectWith(tempURL: URL) -> URL?
  
  /// Сохраняет изображение в галерее устройства.
  func saveImageToGallery(_ imageURL: URL, completion: ((Bool) -> Void)?)
  
  /// Получить имя файла по URL
  func getFileName(from url: URL) -> String?
  
  /// Сохраняет видео в галерее устройства.
  /// - Parameters:
  ///   - video: Ссылка на видео
  ///   - completion: Коллбэк, который вызывается после попытки сохранения. Передает `Bool`, указывающий успешно ли было сохранение видео.
  func saveVideoToGallery(_ video: URL?, completion: ((Bool) -> Void)?)
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
  private let dataManagementService: IDataManagerService
  private let uiService: IUIService
  private let permissionService: IPermissionService
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///   - services: Сервисы
  init(services: IApplicationServices) {
    modelHandlerService = services.messengerService.modelHandlerService
    systemService = services.userInterfaceAndExperienceService.systemService
    cryptoService = services.accessAndSecurityManagementService.cryptoService
    notificationService = services.userInterfaceAndExperienceService.notificationService
    dataManagementService = services.dataManagementService.dataManagerService
    uiService = services.userInterfaceAndExperienceService.uiService
    permissionService = services.accessAndSecurityManagementService.permissionService
  }
}

// MARK: - MessengerDialogScreenInteractorInput

extension MessengerDialogScreenInteractor: MessengerDialogScreenInteractorInput {
  func getFileName(from url: URL) -> String? {
    dataManagementService.getFileName(from: url)
  }
  
  func saveImageToGallery(_ imageURL: URL, completion: ((Bool) -> Void)?) {
    let dataImage = dataManagementService.readObjectWith(fileURL: imageURL)
    
    Task { [weak self] in
      guard let self, await permissionService.requestGallery() else {
        completion?(false)
        return
      }
      
      await uiService.saveImageToGallery(dataImage)
      completion?(true)
    }
  }
  
  func saveVideoToGallery(_ video: URL?, completion: ((Bool) -> Void)?) {
    Task {
      guard await permissionService.requestGallery() else {
        completion?(false)
        return
      }
      await uiService.saveVideoToGallery(video)
      completion?(true)
    }
  }
  
  func saveObjectWith(tempURL: URL) -> URL? {
    dataManagementService.saveObjectWith(tempURL: tempURL)
  }
  
  func copyToClipboard(text: String) {
    systemService.copyToClipboard(text: text)
  }
  
  func showNotification(_ type: SKAbstractions.NotificationServiceType) {
    DispatchQueue.main.async { [weak self] in
      self?.notificationService.showNotification(type)
    }
  }
  
  func getNewContactModels(_ contactModel: ContactModel) async -> ContactModel {
    let contactModels = await modelHandlerService.getContactModels()
    if let contactIndex = contactModels.firstIndex(where: { $0.toxAddress == contactModel.toxAddress }) {
      return contactModels[contactIndex]
    }
    return contactModel
  }
}

// MARK: - Private

private extension MessengerDialogScreenInteractor {}

// MARK: - Constants

private enum Constants {}
