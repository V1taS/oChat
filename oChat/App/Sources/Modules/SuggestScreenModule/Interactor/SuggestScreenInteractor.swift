//
//  SuggestScreenInteractor.swift
//  oChat
//
//  Created by Vitalii Sosin on 19.04.2024.
//

import SwiftUI
import SKAbstractions

/// События которые отправляем из Interactor в Presenter
protocol SuggestScreenInteractorOutput: AnyObject {}

/// События которые отправляем от Presenter к Interactor
protocol SuggestScreenInteractorInput {
  /// Запрос доступа к Уведомлениям
  /// - Parameter granted: Булево значение, указывающее, было ли предоставлено разрешение
  func requestNotification(completion: @escaping (_ granted: Bool) -> Void)
  /// Метод для проверки, включены ли уведомления
  /// - Parameter enabled: Булево значение, указывающее, было ли включено уведомление
  func isNotificationsEnabled(completion: @escaping (_ enabled: Bool) -> Void)
  /// Запрос доступа к Face ID для аутентификации
  /// - Parameter granted: Булево значение, указывающее, было ли предоставлено разрешение
  func requestFaceID(completion: @escaping (_ granted: Bool) -> Void)
  /// Получает модель настроек приложения `AppSettingsModel` асинхронно.
  /// - Parameter completion: Блок завершения, который вызывается с `AppSettingsModel` после завершения операции.
  func getAppSettingsModel(completion: @escaping (AppSettingsModel) -> Void)
  /// Включает или отключает аутентификацию по Face ID.
  /// - Parameters:
  ///   - value: Значение, указывающее, следует ли включить аутентификацию по Face ID.
  ///   - completion: Опциональный блок завершения, вызываемый после сохранения изменений.
  func setIsEnabledFaceID(_ value: Bool, completion: (() -> Void)?)
  /// Включает или отключает уведомления в приложении.
  /// - Parameters:
  ///   - value: Значение, указывающее, следует ли включить уведомления.
  ///   - completion: Опциональный блок завершения, вызываемый после сохранения изменений.
  func setIsEnabledNotifications(_ value: Bool, completion: (() -> Void)?)
}

/// Интерактор
final class SuggestScreenInteractor {
  
  // MARK: - Internal properties
  
  weak var output: SuggestScreenInteractorOutput?
  
  // MARK: - Private properties
  
  private let permissionService: IPermissionService
  private let modelHandlerService: IMessengerModelHandlerService
  private let appSettingsManager: IAppSettingsManager
  
  /// - Parameters:
  ///   - services: Сервисы
  init(services: IApplicationServices) {
    permissionService = services.accessAndSecurityManagementService.permissionService
    modelHandlerService = services.messengerService.modelHandlerService
    appSettingsManager = services.messengerService.appSettingsManager
  }
}

// MARK: - SuggestScreenInteractorInput

extension SuggestScreenInteractor: SuggestScreenInteractorInput {
  func isNotificationsEnabled(completion: @escaping (Bool) -> Void) {
    Task {
      let isNotificationsEnabled = await permissionService.isNotificationsEnabled()
      completion(isNotificationsEnabled)
    }
  }
  
  func requestNotification(completion: @escaping (Bool) -> Void) {
    Task {
      let granted = await permissionService.requestNotification()
      completion(granted)
    }
  }
  
  func requestFaceID(completion: @escaping (Bool) -> Void) {
    Task {
      let granted = await permissionService.requestFaceID()
      completion(granted)
    }
  }
  
  func getAppSettingsModel(completion: @escaping (SKAbstractions.AppSettingsModel) -> Void) {
    modelHandlerService.getAppSettingsModel(completion: completion)
  }
  
  func setIsEnabledFaceID(_ value: Bool, completion: (() -> Void)?) {
    appSettingsManager.setIsEnabledFaceID(value, completion: completion)
  }
  
  func setIsEnabledNotifications(_ value: Bool, completion: (() -> Void)?) {
    appSettingsManager.setIsEnabledNotifications(value, completion: completion)
  }
}

// MARK: - Private

private extension SuggestScreenInteractor {}

// MARK: - Constants

private enum Constants {}
